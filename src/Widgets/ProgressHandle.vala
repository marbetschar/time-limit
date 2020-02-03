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

    private void arrow_move (double progress) {
        Gtk.Allocation alloc;
        get_allocation (out alloc);

        Gtk.Allocation arrow_alloc;
        arrow.get_allocation (out arrow_alloc);

        var angle = -progress * Math.PI * 2 + Math.PI / 2;
        var x = alloc.width / 2 + Math.cos (angle) * alloc.width / 2;
        var y = alloc.height / 2 + Math.sin (angle) * alloc.height / 2;

        move (arrow, (int) (x - arrow_alloc.width / 2), (int) (y - arrow_alloc.height / 2));
    }
}
