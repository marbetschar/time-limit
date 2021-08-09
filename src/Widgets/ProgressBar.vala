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

public class Timer.Widgets.ProgressBar : Gtk.DrawingArea {

    private Gdk.Point center;
    private int radius;

    public double progress { get; construct set; }

    public ProgressBar (double progress) {
        Object (progress: progress);
    }

    construct {
        size_allocate.connect (() => {
            int width = get_allocated_width ();
            int height = get_allocated_height ();

            radius = (width - margin_start - margin_end) / 2;

            center = Gdk.Point () {
                x = width / 2,
                y = height / 2
            };
        });
    }

    public override bool draw (Cairo.Context context) {
        int width = get_allocated_width ();
        int height = get_allocated_height ();

        context.move_to (center.x, 0);
        double angle = progress * Math.PI * 2;

        var arc_angle_from = -Math.PI / 2;
        var arc_angle_to = arc_angle_from + (progress > 1 ? Math.PI * 2 : angle);

        context.arc (center.x, center.y, radius, arc_angle_from, arc_angle_to);
        context.line_to (center.x, center.y);

        context.translate (center.x, center.y);
        context.rotate (angle);
        context.translate (-center.x, -center.y);
        context.clip ();

        Gdk.RGBA light_rgba, medium_rgba, dark_rgba;
        var style_context = get_style_context ();

        if (!style_context.lookup_color ("accent_color_500", out light_rgba)) {
            light_rgba = { 0.19845, 0.5485, 0.9665, 1 };
        }

        if (!style_context.lookup_color ("accent_color_700", out medium_rgba)) {
            medium_rgba = { 0.101562, 0.414062, 0.789062, 1 };
        }

        if (!style_context.lookup_color ("accent_color_900", out dark_rgba)) {
            dark_rgba = { 0.015625, 0.300781, 0.644531, 1 };
        }

        var light_medium_gradient = new Cairo.Pattern.linear (width * 0.25, 0, width * 0.25, height * 0.6);
        light_medium_gradient.add_color_stop_rgba (0, light_rgba.red, light_rgba.green, light_rgba.blue, light_rgba.alpha);
        light_medium_gradient.add_color_stop_rgba (height, medium_rgba.red, medium_rgba.green, medium_rgba.blue, medium_rgba.alpha);
        context.set_source (light_medium_gradient);
        context.rectangle (0, 0, width / 2 + 1, height);
        context.fill();

        var dark_medium_gradient = new Cairo.Pattern.linear (width * 0.75, 0, width * 0.75, height * 0.6);
        dark_medium_gradient.add_color_stop_rgba (0, dark_rgba.red, dark_rgba.green, dark_rgba.blue, dark_rgba.alpha);
        dark_medium_gradient.add_color_stop_rgba (height, medium_rgba.red, medium_rgba.green, medium_rgba.blue, medium_rgba.alpha);
        context.set_source (dark_medium_gradient);
        context.rectangle (width / 2, 0, width / 2 + 1, height);
        context.fill();

        return false;
    }
}
