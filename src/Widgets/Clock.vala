/*
* Copyright (c) 2022 Marco Betschart (https://marco.betschart.name)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Marco Betschart <time-limit@marco.betschart.name
*/

public class Timer.Widgets.Clock : Gtk.Box {

    public double progress { get; set; }
    public double seconds { get; set; }
    public bool pause { get; set; }

    private LoginManager login_manager;
    private GLib.DateTime? suspend_datetime = null;

    private uint update_labels_timeout_id = 0U;
    private uint ticking_timeout_id = 0U;
    private double on_button_press_seconds;
    private bool on_button_press_pause;
    private bool button_press_active;

    private Gtk.Overlay overlay;
    private Timer.Widgets.ProgressIndicator indicator;
    private Timer.Widgets.Face face;
    private Timer.Widgets.Labels labels;

    private double progress_total_seconds;

    public Clock () {
        Object (
            orientation: Gtk.Orientation.VERTICAL,
            spacing: 0
        );
    }

    construct {
        progress = 0.0;
        seconds = 0.0;
        pause = false;

        on_button_press_seconds = 0.0;
        on_button_press_pause = false;
        button_press_active = false;

        indicator = new Timer.Widgets.ProgressIndicator (0.0) {
            vexpand = true,
            hexpand = true
        };

        face = new Timer.Widgets.Face () {
            margin_top = 20,
            margin_bottom = 20,
            margin_start = 20,
            margin_end = 20
        };

        labels = new Timer.Widgets.Labels () {
            margin_top = 20,
            margin_bottom = 20,
            margin_start = 20,
            margin_end = 20,
            valign = Gtk.Align.CENTER,
            halign = Gtk.Align.CENTER
        };

        overlay = new Gtk.Overlay () {
            width_request = 200,
            height_request = 200
        };
        overlay.add_overlay (indicator);
        overlay.add_overlay (face);
        overlay.add_overlay (labels);
        append (overlay);

        bind_property ("progress", indicator, "progress", BindingFlags.BIDIRECTIONAL);

        var gesture_click = new Gtk.GestureClick ();
        gesture_click.pressed.connect (on_click_pressed);
        gesture_click.released.connect (on_click_released);
        add_controller (gesture_click);

        notify["progress"].connect (on_progress_changed);
        notify["seconds"].connect (on_seconds_changed);
        notify["pause"].connect (on_pause_changed);

        try {
            login_manager = GLib.Bus.get_proxy_sync (BusType.SYSTEM, "org.freedesktop.login1", "/org/freedesktop/login1");
            login_manager.prepare_for_sleep.connect ((start) => {
                if (start) {
                    if (update_labels_timeout_id > 0) {
                        GLib.Source.remove (update_labels_timeout_id);
                        update_labels_timeout_id = 0;
                    }
                    suspend_datetime = new GLib.DateTime.now_local ();
                    GLib.Timeout.add_seconds (1, on_resume);
                }
            });
        } catch(IOError e) {
            warning (e.message);
        }

        update_labels ();
    }

    private void on_click_pressed (int n_press, double x, double y) {
        button_press_active = true;

        on_button_press_seconds = seconds;
        on_button_press_pause = pause;

        pause = true;
    }

    private void on_click_released (int n_press, double x, double y) {
        button_press_active = false;

        if (on_button_press_seconds == seconds && seconds > 0) {
            pause = !on_button_press_pause;

            if (pause) {
                update_labels ();
            }

        } else {
            pause = false;
        }
    }

    private void on_seconds_changed () {
        if (!pause) {
            progress = convert_seconds_to_progress (seconds);
        }

        update_labels ();
    }

    private void on_progress_changed () {
        if (pause) {
            seconds = convert_progress_to_seconds (progress);
            progress_total_seconds = seconds;
            update_labels ();
        }
    }

    private void on_pause_changed () {
        assert (parent is Timer.MainWindow);
        var main_window = (Timer.MainWindow) parent;

        if (!button_press_active && !pause && seconds > 0) {
            start_ticking ();

            var notification_datetime = new GLib.DateTime.now_local ();
            main_window.schedule_notification (notification_datetime.add_seconds (seconds));

        } else {
            main_window.schedule_notification (null);
        }
        update_labels ();
    }

    private bool on_resume () {
        if (!pause && suspend_datetime != null) {
            var now = new GLib.DateTime.now_local ();
            var sleep_seconds = now.difference (suspend_datetime) / 1000000;
            suspend_datetime = null;

            seconds = GLib.Math.fmax(0, seconds - sleep_seconds);
        } else {
            update_labels ();
        }
        return GLib.Source.REMOVE;
    }

    private bool update_labels () {
        if (update_labels_timeout_id > 0) {
            GLib.Source.remove (update_labels_timeout_id);
            update_labels_timeout_id = 0;
        }

        var now = new GLib.DateTime.now_local ();
        var until = now.add_seconds (seconds);
        until = until.add_seconds (-until.get_seconds ());
        labels.time_label.label = until.format ("%R");

        if (seconds < 60) {
            labels.minutes_label.label = "%i\"".printf ((int) seconds);
            labels.seconds_label.label = "";

        } else {
            labels.minutes_label.label = "%i\'".printf ((int) convert_seconds_to_minutes (seconds));
            labels.seconds_label.label = "%i\"".printf ((int) Timer.Util.truncating_remainder (seconds, 60));
        }

        if (!button_press_active && pause && seconds > 0) {
            labels.time_stack.visible_child = labels.time_pause;
        } else {
            labels.time_stack.visible_child = labels.time_label;
        }

        var minute_delta = 60 - now.get_second ();
        update_labels_timeout_id = GLib.Timeout.add_seconds (minute_delta, update_labels);
        return GLib.Source.REMOVE;
    }

    private double scale_original = 6;
    private double scale_actual = 3;

    private double convert_seconds_to_minutes (double seconds) {
        return Math.floor (seconds / 60);
    }

    private double convert_progress_to_seconds (double progress) {
        var scaled_progress = convert_progress_to_scale (progress, convert_seconds_to_minutes (seconds));

        var seconds = Math.round (scaled_progress * 60.0 * 60.0);
        if (seconds <= 300) {
            seconds = seconds - Timer.Util.truncating_remainder (seconds, 10);
        } else {
            seconds = seconds - Timer.Util.truncating_remainder (seconds, 60);
        }

        return seconds;
    }

    private double convert_seconds_to_progress (double seconds) {
        return invert_progress_to_scale(seconds / 3600, convert_seconds_to_minutes(seconds));
    }

    private double convert_progress_to_scale (double progress, double minutes) {
        if (minutes <= 60) {
            if (progress <= scale_original / 60) {
                return progress / (scale_original / scale_actual);
            } else {
                return (progress * 60 - scale_original + scale_actual) / (60 - scale_actual);
            }
        }
        return progress;
    }

    private double invert_progress_to_scale (double progress, double minutes) {
        if (minutes <= 60) {
            if (progress <= scale_actual / 60) {
                return progress * (scale_original / scale_actual);
            } else {
                return (progress * (60 - scale_actual) - scale_actual + scale_original) / 60;
            }
        }
        return progress;
    }

    public void start_ticking () {
        if (ticking_timeout_id != 0) {
            GLib.Source.remove (ticking_timeout_id);
            ticking_timeout_id = 0;
        }

        ticking_timeout_id = Timeout.add_seconds (1, () => {
            if (!pause) {
                seconds = GLib.Math.fmax(0, seconds - 1);
            }
            return !pause && seconds > 0;
        });
    }
}
