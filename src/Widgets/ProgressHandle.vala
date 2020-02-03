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

    public signal void progress_changed (double progress);

    private Timer.Widgets.Arrow arrow;

    private static Gtk.CssProvider css_provider;

    static construct {
        css_provider = new Gtk.CssProvider ();
        css_provider.load_from_resource ("name/betschart/marco/timer/ProgressHandle.css");
    }

    construct {
        arrow = new Timer.Widgets.Arrow ();
        // put (arrow, 0, 0); //x: 86, y: 0
        put (arrow, 86, 0);

        arrow.progress_changed.connect ((progress) => {
            arrow_move (progress);
            progress_changed (progress);
        });
    }

    public void arrow_move (double progress) {
        int arrow_width = arrow.get_allocated_width ();
        int arrow_height = arrow.get_allocated_height ();

        int widget_width = get_allocated_width () - arrow_width;
        int widget_height = get_allocated_height () - arrow_height;

        var angle = progress * Math.PI * 2 + Math.PI / 2;
        var delta_x = widget_width / 2 + Math.cos (angle) * widget_width / 2;
        var delta_y = widget_height / 2 + Math.sin (angle) * widget_height / 2;

        move (arrow, (int) delta_x, (int) delta_y);
    }
}
