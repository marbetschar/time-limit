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
* Authored by: Marco Betschart <elementary-timer@marco.betschart.name
*/

public class Timer.Widgets.Clock : Gtk.Overlay {

    private double seconds { get; set; }

    private double minutes {
        get { return Math.floor (seconds / 60); }
    }

    private Timer.Widgets.ProgressIndicator indicator;
    private Timer.Widgets.Face face;
    private Timer.Widgets.Labels labels;

    private static Gtk.CssProvider css_provider;

    static construct {
        css_provider = new Gtk.CssProvider ();
        css_provider.load_from_resource ("name/betschart/marco/timer/Clock.css");
    }

    construct {
        add_events (Gdk.EventMask.BUTTON_RELEASE_MASK);

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
        context.add_class ("clock");
        context.add_provider (css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        button_release_event.connect (on_button_release_event);

        indicator.progress_changed.connect ((progress) => {
            var scaled_progress = convert_progress_to_scale (progress);

            var seconds = Math.round (scaled_progress * 60.0 * 60.0);
            if (seconds <= 300) {
                seconds = seconds - Timer.Util.truncating_remainder (seconds, 10);
            } else {
                seconds = seconds - Timer.Util.truncating_remainder (seconds, 60);
            }

            this.seconds = seconds;
            update_request ();
        });

        update_request ();
    }

    private bool paused = true;

    private bool on_button_release_event (Gdk.EventButton event) {
        if (paused) {
            paused = false;
            Timeout.add_seconds (1, tick);
        }
        return Gdk.EVENT_PROPAGATE;
    }

    private bool tick () {
        debug ("Timeout.callback: %i", (int) this.seconds);
        if (paused || this.seconds <= 0) {
            return false;
        }
        indicator.progress = invert_progress_to_scale ((this.seconds - 1) / 60 / 60);

        return true;
    }

    private void update_request () {
        var until = new DateTime.now_local ();
        until = until.add_seconds (seconds);
        until = until.add_seconds (-until.get_seconds ());
        labels.time_label.label = until.format ("%R");

        if (seconds < 60) {
            labels.minutes_label.label = "%i\"".printf ((int) seconds);
            labels.seconds_label.label = "";

        } else {
            labels.minutes_label.label = "%i\'".printf ((int) minutes);
            labels.seconds_label.label = "%i\"".printf ((int) Timer.Util.truncating_remainder (seconds, 60));
        }
    }

    private double scaleOriginal = 6;
    private double scaleActual = 3;

    private double convert_progress_to_scale (double progress) {
        if (minutes <= 60) {
            if (progress <= scaleOriginal / 60) {
                return progress / (scaleOriginal / scaleActual);
            } else {
                return (progress * 60 - scaleOriginal + scaleActual) / (60 - scaleActual);
            }
        }
        return progress;
    }

    private double invert_progress_to_scale (double progress) {
        if (minutes <= 60) {
            if (progress <= scaleActual / 60) {
                return progress * (scaleOriginal / scaleActual);
            } else {
                return (progress * (60 - scaleActual) - scaleActual + scaleOriginal) / 60;
            }
        }
        return progress;
    }
}
