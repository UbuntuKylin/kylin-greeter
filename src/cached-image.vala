/* -*- Mode: Vala; indent-tabs-mode: nil; tab-width: 4 -*-
 *
 * Copyright (C) 2012 Canonical Ltd
 *               2015, National University of Defense Technology(NUDT) & Kylin Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors: Michael Terry <michael.terry@canonical.com>
 * Modified by : zhangchao <zhangchao@ubuntukylin.com>
 */

public class CachedImage : Gtk.Image
{
    private static HashTable<Gdk.Pixbuf, Cairo.Surface> surface_table;
    //private Gtk.Allocation allocation;
    private bool draw_border=false; 
    public static Cairo.Surface? get_cached_surface (Cairo.Context c, Gdk.Pixbuf pixbuf)
    {
        if (surface_table == null)
            surface_table = new HashTable<Gdk.Pixbuf, Cairo.Surface> (direct_hash, direct_equal);

        var surface = surface_table.lookup (pixbuf);
        if (surface == null)
        {
            surface = new Cairo.Surface.similar (c.get_target (), Cairo.Content.COLOR_ALPHA, pixbuf.width, pixbuf.height);
            var new_c = new Cairo.Context (surface);
            Gdk.cairo_set_source_pixbuf (new_c, pixbuf, 0, 0);
            new_c.paint ();
            surface_table.insert (pixbuf, surface);
        }
        return surface;
    }

    public CachedImage (Gdk.Pixbuf? pixbuf)
    {
        Object (pixbuf: pixbuf);
    }

    public void draw_white_border()
    {
        draw_border=true; 
    }
    public override bool draw (Cairo.Context c)
    {
        if (pixbuf != null)
        {
            var cached_surface = get_cached_surface (c, pixbuf);
            if (cached_surface != null)
            {
                c.set_source_surface (cached_surface, 0, 0);
                c.paint ();
            }
        }
        if(draw_border)
        {
        //白色描边
        c.save ();
        //get_allocation (out allocation);
        CairoUtils.rounded_rectangle (c, 0, 0, pixbuf.width,  pixbuf.height, 0);
        c.set_source_rgba (1.0, 1.0,1.0 , 0.8);
        c.set_line_width (4);
        c.stroke ();
        c.restore ();
        }
        return false;
    }
}
