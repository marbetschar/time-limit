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

public class Timer.Widgets.ProgressArrow : Gtk.DrawingArea {

    public double progress { get; construct set; }
    public bool is_active { get; private set; }

    public ProgressArrow (double progress) {
        Object (progress: progress);
    }

    construct {
        set_css_name ("arrow");
        set_draw_func (draw);
        notify["progress"].connect (queue_draw);

        is_active = false;

        var gesture_click = new Gtk.GestureClick ();
        gesture_click.pressed.connect (on_click_pressed);
        gesture_click.released.connect (on_click_released);
        add_controller (gesture_click);

        var event_controller_motion = new Gtk.EventControllerMotion ();
        event_controller_motion.motion.connect (on_motion);
        add_controller (event_controller_motion);
    }

    private void draw (Gtk.DrawingArea area, Cairo.Context context, int width, int height) {
        double angle = progress * Math.PI * 2 - Math.PI;
        context.translate (width / 2, height / 2);
        context.rotate (angle);
        context.translate (-(width / 2), -(height / 2));

        context.move_to (0, 0);
        context.line_to (width / 2, height * 0.8);
        context.line_to (width, 0);
        context.close_path ();

        Gdk.RGBA rgba;
        if (!get_style_context ().lookup_color ("accent_color_500", out rgba)) {
            rgba = { 0.19845f, 0.5485f, 0.9665f, 1 };
        }
        context.set_source_rgba (rgba.red, rgba.green, rgba.blue, rgba.alpha);
        context.fill ();
    }

    private void on_click_pressed (int n_press, double x, double y) {
        if (!is_active) {
            is_active = true;
        }
    }

    private void on_click_released (int n_press, double x, double y) {
        if (is_active) {
            is_active = false;
        }
    }

    private void on_motion (double x, double y) {
        if (is_active) {
            var parent_center_x = parent.get_allocated_width () / 2;
            var parent_center_y = parent.get_allocated_height () / 2;

            var arrow_width = get_allocated_width ();
            var arrow_height = get_allocated_height ();

            double arrow_center_x, arrow_center_y;
            translate_coordinates (parent, arrow_width / 2, arrow_height / 2, out arrow_center_x, out arrow_center_y);

            var delta_x = (arrow_center_x + x - parent_center_x) / parent_center_x;
            var delta_y = (arrow_center_y + y - parent_center_y) / -parent_center_y;

            var angle = Math.atan (delta_y / delta_x);
            if (delta_x < 0) {
                angle = angle - Math.PI;
            }
            var progress_new = (progress - Timer.Util.truncating_remainder (progress, 1)) + -(angle - Math.PI / 2) / (Math.PI * 2.0);

            if (progress - progress_new > 0.25) {
                progress_new += 1;
            } else if (progress_new - progress > 0.75) {
                progress_new -= 1;
            }
            if (progress_new < 0) {
                progress_new = 0;
            }

            progress = progress_new;
        }
    }
}
