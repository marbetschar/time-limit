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

public class Timer.Widgets.ProgressArrow : Gtk.DrawingArea {

    public signal void progress_changed (double progress);

    public double progress { get; construct set; }

    public ProgressArrow (double progress) {
        Object (progress: progress);
    }

    construct {
        set_size_request (25, 25);

        add_events (Gdk.EventMask.BUTTON_PRESS_MASK
                  | Gdk.EventMask.BUTTON_RELEASE_MASK
                  | Gdk.EventMask.POINTER_MOTION_MASK);

        button_press_event.connect (on_button_press_event);
        button_release_event.connect (on_button_release_event);
        motion_notify_event.connect (on_motion_notify_event);
    }

    public override bool draw (Cairo.Context context) {
        int width = get_allocated_width ();
        int height = get_allocated_height ();

        double angle = progress * Math.PI * 2 - Math.PI;
        context.translate (width / 2, height / 2);
        context.rotate (angle);
        context.translate (-(width / 2), -(height / 2));

        context.move_to (0, 0);
        context.line_to (width / 2, height * 0.8);
        context.line_to (width, 0);
        context.close_path ();
        context.set_source_rgba (0.19845, 0.5485, 0.9665, 1);
        context.fill ();

        return true;
    }

    private bool drag_is_active = false;

    private bool on_button_press_event (Gdk.EventButton event) {
        if (!drag_is_active) {
            drag_is_active = true;
        }
        return true;
    }

    private bool on_button_release_event (Gdk.EventButton event) {
        if (drag_is_active) {
            drag_is_active = false;
        }
        return true;
    }

    private bool on_motion_notify_event (Gdk.EventMotion event) {
        if (drag_is_active) {
            var parent_center_x = parent.get_allocated_width () / 2;
            var parent_center_y = parent.get_allocated_height () / 2;

            var arrow_width = get_allocated_width ();
            var arrow_height = get_allocated_height ();

            int arrow_center_x, arrow_center_y;
            translate_coordinates (parent, arrow_width / 2, arrow_height / 2, out arrow_center_x, out arrow_center_y);

            var delta_x = (arrow_center_x + event.x - parent_center_x) / parent_center_x;
            var delta_y = (arrow_center_y + event.y - parent_center_y) / -parent_center_y;

            var angle = Math.atan (delta_y / delta_x);
            if (delta_x < 0) {
                angle = angle - Math.PI;
            }
            var progress_motion = (progress - Timer.Util.truncating_remainder (progress, 1)) + -(angle - Math.PI / 2) / (Math.PI * 2.0);

            if (progress - progress_motion > 0.25) {
                progress_motion += 1;
            } else if (progress_motion - progress > 0.75) {
                progress_motion -= 1;
            }
            if (progress_motion < 0) {
                progress_motion = 0;
            }
            progress = progress_motion;

            queue_draw ();
            progress_changed (progress);

        }
        return true;
    }
}
