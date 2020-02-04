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

public class Timer.Widgets.ProgressBar : Gtk.DrawingArea {

    private Gdk.Pixbuf background;
    private Gdk.Point center;
    private int radius;

    public double progress { get; construct set; }

    public ProgressBar (double progress) {
        Object (progress: progress);
    }

    construct {
        try {
            background = new Gdk.Pixbuf.from_resource ("/name/betschart/marco/timer/progress.png");
            set_size_request (192, 192); // TODO: Make size allocation dynamic to support resizing
        } catch (Error e) {
            warning (e.message);
        }

        size_allocate.connect (() => {
            int width = get_allocated_width ();
            int height = get_allocated_height ();

            radius = (width - margin * 2) / 2;

            center = Gdk.Point () {
                x = width / 2,
                y = height / 2
            };

            background = background.scale_simple (width - margin, height - margin, Gdk.InterpType.BILINEAR);
        });
    }

    public override bool draw (Cairo.Context context) {
        if (background == null) {
            return false;
        }
        context.move_to (center.x, 0);

        double angle = progress * Math.PI * 2;

        var arc_angle_from = -Math.PI / 2;
        var arc_angle_to = arc_angle_from + (progress > 1 ? Math.PI * 2 : angle);

        context.arc (center.x, center.y, radius, arc_angle_from, arc_angle_to);
        context.line_to (center.x, center.y);

        context.translate (center.x, center.y);
        context.rotate (angle);
        context.translate (-center.x, -center.y);

        Gdk.cairo_set_source_pixbuf (context, background, margin, margin);

        context.fill ();

        return true;
    }
}
