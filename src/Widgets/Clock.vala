/*
* Copyright (c) 2020 Marco Betschart (https://marco.betschart.name)
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

public class Timer.Widgets.Clock : Gtk.Overlay {

    public double progress { get; set; }
    public double seconds { get; set; }
    public bool pause { get; set; }

    private double on_button_press_seconds;
    private bool on_button_press_pause;
    private bool button_press_active;

    private Timer.Widgets.ProgressIndicator indicator;
    private Timer.Widgets.Face face;
    private Timer.Widgets.Labels labels;

    private Unity.LauncherEntry launcher_entry;
    private double launcher_entry_total_seconds;

    private static Gtk.CssProvider css_provider;

    static construct {
        css_provider = new Gtk.CssProvider ();
        css_provider.load_from_resource ("com/github/marbetschar/time-limit/Main.css");
    }

    construct {
        progress = 0.0;
        seconds = 0.0;
        pause = false;

        on_button_press_seconds = 0.0;
        on_button_press_pause = false;
        button_press_active = false;

        launcher_entry = Unity.LauncherEntry.get_for_desktop_id ("com.github.marbetschar.time-limit.desktop");

        indicator = new Timer.Widgets.ProgressIndicator (0.0);

        face = new Timer.Widgets.Face ();
        face.margin = 20;

        labels = new Timer.Widgets.Labels ();
        labels.margin = 20;
        labels.valign = Gtk.Align.CENTER;
        labels.halign = Gtk.Align.CENTER;

        add (indicator);
        add_overlay (face);
        add_overlay (labels);

        var context = get_style_context ();
        context.add_class ("main");
        context.add_provider (css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        bind_property ("progress", indicator, "progress", BindingFlags.BIDIRECTIONAL);

        add_events (Gdk.EventMask.BUTTON_PRESS_MASK
                  | Gdk.EventMask.BUTTON_RELEASE_MASK);

        button_press_event.connect (on_button_press_event);
        button_release_event.connect (on_button_release_event);

        notify["progress"].connect (on_progress_changed);
        notify["seconds"].connect (on_seconds_changed);
        notify["pause"].connect (on_pause_changed);

        update_labels ();
    }

    private bool on_button_press_event (Gdk.EventButton event) {
        button_press_active = true;

        on_button_press_seconds = seconds;
        on_button_press_pause = pause;

        pause = true;

        return Gdk.EVENT_PROPAGATE;
    }

    private bool on_button_release_event (Gdk.EventButton event) {
        button_press_active = false;

        if (on_button_press_seconds == seconds && seconds > 0) {
            pause = !on_button_press_pause;

            if (pause) {
                update_labels ();
            }

        } else {
            pause = false;
        }

        return Gdk.EVENT_PROPAGATE;
    }

    private void on_seconds_changed () {
        if (!pause) {
            launcher_entry.progress_visible = true;

            progress = convert_seconds_to_progress (seconds);
            launcher_entry.progress = 1 - seconds / launcher_entry_total_seconds;

            update_labels ();
        }

        if (seconds <= 0) {
            launcher_entry.progress_visible = false;
        }
    }

    private void on_progress_changed () {
        if (pause) {
            launcher_entry.progress_visible = false;

            seconds = convert_progress_to_seconds (progress);
            launcher_entry_total_seconds = seconds;
            update_labels ();
        }
    }

    private void on_pause_changed () {
        if (!button_press_active && !pause && seconds > 0) {
            Timeout.add_seconds (1, () => {
                if (!pause) {
                    var seconds_new = seconds - 1;
                    seconds = seconds_new > 0 ? seconds_new : 0;

                    if (seconds == 0) {
                        var main_window = (Timer.MainWindow) parent;
                        var notification = new Notification (_("It's time!"));
                        notification.set_body (_("Your time limit is over."));
                        main_window.send_notification (notification);
                    }
                }
                return !pause && seconds > 0;
            });
        }
        update_labels ();
    }

    private void update_labels () {
        var until = new DateTime.now_local ();
        until = until.add_seconds (seconds);
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
}
