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

namespace Tests {

    int main(string[] args) {
        Test.init (ref args);

        // Using GLib.TestSuite allows for set_up/tear_down methods:
        Test.get_root ().add(new Util.TruncatingRemainder ());

        // If we don't need the set_up/tear_down methods, we can simply register a function:
        Test.add_func("/Util/truncating_remaindssser", Util.test_truncating_remainder);

        return Test.run();
    }
}