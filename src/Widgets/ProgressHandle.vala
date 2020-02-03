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

public class Timer.Widgets.ProgressHandle : Gtk.Fixed {

    public double progress { get; set; }

    private Timer.Widgets.Arrow arrow;

    private static Gtk.CssProvider css_provider;

    static construct {
        css_provider = new Gtk.CssProvider ();
        css_provider.load_from_resource ("name/betschart/marco/timer/ProgressHandle.css");
    }

    construct {
        arrow = new Timer.Widgets.Arrow ();
        put (arrow, 0, 0); //x: 86, y: 0

        progress = 0.0;

        notify["progress"].connect(() => {
            debug ("progress: %f.", this.progress);
            arrow.progress = progress;
        });

        size_allocate.connect (on_size_allocate);

        arrow.button_press_event.connect (arrow_on_button_press_event);
        arrow.button_release_event.connect (arrow_on_button_release_event);
        arrow.motion_notify_event.connect (arrow_on_motion_notify_event);
    }

    private void on_size_allocate (Gtk.Allocation alloc) {
        Gtk.Allocation arrow_alloc;
        arrow.get_allocation (out arrow_alloc);

        move (arrow, alloc.width / 2 - arrow_alloc.width / 2, 0);
    }

    private bool arrow_drag_enabled = false;

    private bool arrow_on_button_press_event (Gdk.EventButton event) {
        if (!arrow_drag_enabled) {
            arrow_drag_enabled = true;
        }
        return true;
    }

    private bool arrow_on_button_release_event (Gdk.EventButton event) {
        if (arrow_drag_enabled) {
            arrow_drag_enabled = false;
        }
        return true;
    }

    private bool arrow_on_motion_notify_event (Gdk.EventMotion event) {
        if (arrow_drag_enabled) {
            move (arrow, (int) event.x, (int) event.y);
            /*
            Gtk.Allocation alloc;
            get_allocation (out alloc);

            var center_x = alloc.width / 2; // + alloc.x;
            var center_y = alloc.height / 2; // + alloc.y;

            var delta_x = (event.x - center_x) / center_x;
            var delta_y = (event.y - center_y) / center_y;

            var angle = Math.atan (delta_y / delta_x);
            if (delta_x < 0) {
                angle = angle - Math.PI;
            }

            var progress = (arrow.progress - Math.trunc (Math.remainder (arrow.progress, 1))) + -(angle - Math.PI / 2.0) / (Math.PI * 2.0);
            if (arrow.progress - progress > 0.25) {
                progress += 1;
            } else if (progress - arrow.progress > 0.75) {
                progress -= 1;
            }
            if (progress < 0) {
                progress = 0;
            }

            var arrow_angle = -progress * Math.PI * 2 + Math.PI / 2;
            var arrow_x = center_x + Math.cos (arrow_angle) * center_x;
            var arrow_y = center_y + Math.sin (arrow_angle) * center_y;

            //arrow.progress = convert_progress_to_scale (progress);
            */
        }
        return true;
    }

    private double scaleOriginal = 6;
    private double scaleActual = 3;

    private double convert_progress_to_scale (double progress) {
        if (progress <= scaleOriginal / 60) {
            return progress / (scaleOriginal / scaleActual);
        } else {
            return (progress * 60 - scaleOriginal + scaleActual) / (60 - scaleActual);
        }
    }
}
