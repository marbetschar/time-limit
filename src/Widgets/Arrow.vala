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

public class Timer.Widgets.Arrow : Gtk.DrawingArea {

    private double progress { get; set; }
    public signal void progress_changed (double progress);

    construct {
        set_size_request (25, 25);

        progress = 0.0;

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

        double angle = progress * Math.PI * 2;
        context.translate (width / 2, height / 2);
        context.rotate (angle);
        context.translate (-(width / 2), -(height / 2));

        context.move_to (0, height);
        context.line_to (width / 2, height * 0.2);
        context.line_to (width, height);
        context.close_path ();
        context.set_source_rgba (0.19845, 0.5485, 0.9665, 1);
        context.fill ();

        return true;

    /*
    if windowHasFocus {
      let ratio: CGFloat = 0.5
      NSColor(srgbRed: 0.1734 + ratio * (0.2235 - 0.1734), green: 0.5284 + ratio * (0.5686 - 0.5284), blue: 0.9448 + ratio * (0.9882 - 0.9448), alpha: 1.0).setFill()
    } else {
      NSColor(srgbRed: 0.5529, green: 0.6275, blue: 0.7216, alpha: 1.0).setFill()
    }
    */
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
            Gtk.Allocation alloc;
            get_allocation (out alloc);

            var center_x = alloc.x + alloc.width / 2;
            var center_y = alloc.y + alloc.height / 2;

            var delta_x = (event.x - center_x) / center_x;
            var delta_y = (event.y - center_y) / center_y;

            //debug ("event.x: %f, center_x: %f", event.x, center_x);
            //debug ("event.y: %f, center_y: %f", event.y, center_y);
            // debug ("delta_x; %f, delta_y: %f", delta_x, delta_y);

            var angle = Math.atan (delta_y / delta_x);
            if (delta_x < 0) {
                angle = angle - Math.PI;
            }

            var motion_progress = (progress - Math.fabs (Math.remainder (progress, 1))) + -(angle - Math.PI / 2.0) / (Math.PI * 2.0);
            if (progress - motion_progress > 0.25) {
                motion_progress += 1;
            } else if (motion_progress - progress > 0.75) {
                motion_progress -= 1;
            }
            if (progress < 0) {
                motion_progress = 0;
            }
            progress = motion_progress;

            queue_draw ();
            progress_changed (progress);

            /*
            var arrow_angle = -progress * Math.PI * 2 + Math.PI / 2;
            var arrow_x = center_x + Math.cos (arrow_angle) * center_x;
            var arrow_y = center_y + Math.sin (arrow_angle) * center_y;
            */

            //arrow.progress = convert_progress_to_scale (progress);
            //move (arrow, (int) event.x, (int) event.y);
            // move (arrow, (int) arrow_x, (int) arrow_y);
        }
        return true;
    }
}
