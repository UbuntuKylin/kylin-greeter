/* dash-button.c generated by valac 0.22.1, the Vala compiler
 * generated from dash-button.vala, do not modify */

/* -*- Mode: Vala; indent-tabs-mode: nil; tab-width: 4 -*-
 *
 * Copyright (C) 2012 Canonical Ltd
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
 */

#include <glib.h>
#include <glib-object.h>
#include <gtk/gtk.h>
#include <stdlib.h>
#include <string.h>
#include "config.h"
#include <gdk-pixbuf/gdk-pixbuf.h>
#include <cairo.h>
#include <float.h>
#include <math.h>


#define TYPE_FLAT_BUTTON (flat_button_get_type ())
#define FLAT_BUTTON(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_FLAT_BUTTON, FlatButton))
#define FLAT_BUTTON_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_FLAT_BUTTON, FlatButtonClass))
#define IS_FLAT_BUTTON(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_FLAT_BUTTON))
#define IS_FLAT_BUTTON_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_FLAT_BUTTON))
#define FLAT_BUTTON_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_FLAT_BUTTON, FlatButtonClass))

typedef struct _FlatButton FlatButton;
typedef struct _FlatButtonClass FlatButtonClass;
typedef struct _FlatButtonPrivate FlatButtonPrivate;

#define TYPE_FADABLE (fadable_get_type ())
#define FADABLE(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_FADABLE, Fadable))
#define IS_FADABLE(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_FADABLE))
#define FADABLE_GET_INTERFACE(obj) (G_TYPE_INSTANCE_GET_INTERFACE ((obj), TYPE_FADABLE, FadableIface))

typedef struct _Fadable Fadable;
typedef struct _FadableIface FadableIface;

#define TYPE_FADE_TRACKER (fade_tracker_get_type ())
#define FADE_TRACKER(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_FADE_TRACKER, FadeTracker))
#define FADE_TRACKER_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_FADE_TRACKER, FadeTrackerClass))
#define IS_FADE_TRACKER(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_FADE_TRACKER))
#define IS_FADE_TRACKER_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_FADE_TRACKER))
#define FADE_TRACKER_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_FADE_TRACKER, FadeTrackerClass))

typedef struct _FadeTracker FadeTracker;
typedef struct _FadeTrackerClass FadeTrackerClass;

#define TYPE_DASH_BUTTON (dash_button_get_type ())
#define DASH_BUTTON(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_DASH_BUTTON, DashButton))
#define DASH_BUTTON_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_DASH_BUTTON, DashButtonClass))
#define IS_DASH_BUTTON(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_DASH_BUTTON))
#define IS_DASH_BUTTON_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_DASH_BUTTON))
#define DASH_BUTTON_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_DASH_BUTTON, DashButtonClass))

typedef struct _DashButton DashButton;
typedef struct _DashButtonClass DashButtonClass;
typedef struct _DashButtonPrivate DashButtonPrivate;
#define _g_object_unref0(var) ((var == NULL) ? NULL : (var = (g_object_unref (var), NULL)))
#define _g_free0(var) (var = (g_free (var), NULL))

#define TYPE_CACHED_IMAGE (cached_image_get_type ())
#define CACHED_IMAGE(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_CACHED_IMAGE, CachedImage))
#define CACHED_IMAGE_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_CACHED_IMAGE, CachedImageClass))
#define IS_CACHED_IMAGE(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_CACHED_IMAGE))
#define IS_CACHED_IMAGE_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_CACHED_IMAGE))
#define CACHED_IMAGE_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_CACHED_IMAGE, CachedImageClass))

typedef struct _CachedImage CachedImage;
typedef struct _CachedImageClass CachedImageClass;
#define _g_error_free0(var) ((var == NULL) ? NULL : (var = (g_error_free (var), NULL)))

struct _FlatButton {
	GtkButton parent_instance;
	FlatButtonPrivate * priv;
};

struct _FlatButtonClass {
	GtkButtonClass parent_class;
};

struct _FadableIface {
	GTypeInterface parent_iface;
	FadeTracker* (*get_fade_tracker) (Fadable* self);
	void (*set_fade_tracker) (Fadable* self, FadeTracker* value);
};

struct _DashButton {
	FlatButton parent_instance;
	DashButtonPrivate * priv;
};

struct _DashButtonClass {
	FlatButtonClass parent_class;
};

struct _DashButtonPrivate {
	FadeTracker* _fade_tracker;
	GtkLabel* text_label;
	gchar* _text;
};


static gpointer dash_button_parent_class = NULL;
static FadableIface* dash_button_fadable_parent_iface = NULL;

GType flat_button_get_type (void) G_GNUC_CONST;
GType fade_tracker_get_type (void) G_GNUC_CONST;
GType fadable_get_type (void) G_GNUC_CONST;
GType dash_button_get_type (void) G_GNUC_CONST;
#define DASH_BUTTON_GET_PRIVATE(o) (G_TYPE_INSTANCE_GET_PRIVATE ((o), TYPE_DASH_BUTTON, DashButtonPrivate))
enum  {
	DASH_BUTTON_DUMMY_PROPERTY,
	DASH_BUTTON_FADE_TRACKER,
	DASH_BUTTON_TEXT
};
DashButton* dash_button_new (const gchar* text);
DashButton* dash_button_construct (GType object_type, const gchar* text);
FlatButton* flat_button_new (void);
FlatButton* flat_button_construct (GType object_type);
FadeTracker* fade_tracker_new (GtkWidget* widget);
FadeTracker* fade_tracker_construct (GType object_type, GtkWidget* widget);
void fadable_set_fade_tracker (Fadable* self, FadeTracker* value);
void dash_button_set_text (DashButton* self, const gchar* value);
GType cached_image_get_type (void) G_GNUC_CONST;
CachedImage* cached_image_new (GdkPixbuf* pixbuf);
CachedImage* cached_image_construct (GType object_type, GdkPixbuf* pixbuf);
static gboolean dash_button_real_draw (GtkWidget* base, cairo_t* c);
FadeTracker* fadable_get_fade_tracker (Fadable* self);
gdouble fade_tracker_get_alpha (FadeTracker* self);
const gchar* dash_button_get_text (DashButton* self);
static void dash_button_finalize (GObject* obj);
static void _vala_dash_button_get_property (GObject * object, guint property_id, GValue * value, GParamSpec * pspec);
static void _vala_dash_button_set_property (GObject * object, guint property_id, const GValue * value, GParamSpec * pspec);


DashButton* dash_button_construct (GType object_type, const gchar* text) {
	DashButton * self = NULL;
	FadeTracker* _tmp0_ = NULL;
	FadeTracker* _tmp1_ = NULL;
	GtkBox* hbox = NULL;
	GtkBox* _tmp2_ = NULL;
	GtkLabel* _tmp3_ = NULL;
	GtkLabel* _tmp4_ = NULL;
	GtkLabel* _tmp5_ = NULL;
	GtkLabel* _tmp6_ = NULL;
	GtkLabel* _tmp7_ = NULL;
	const gchar* _tmp8_ = NULL;
	gchar* path = NULL;
	gchar* _tmp9_ = NULL;
	GError * _inner_error_ = NULL;
	g_return_val_if_fail (text != NULL, NULL);
	self = (DashButton*) flat_button_construct (object_type);
	_tmp0_ = fade_tracker_new ((GtkWidget*) self);
	_tmp1_ = _tmp0_;
	fadable_set_fade_tracker ((Fadable*) self, _tmp1_);
	_g_object_unref0 (_tmp1_);
	_tmp2_ = (GtkBox*) gtk_box_new (GTK_ORIENTATION_HORIZONTAL, 0);
	g_object_ref_sink (_tmp2_);
	hbox = _tmp2_;
	_tmp3_ = (GtkLabel*) gtk_label_new ("");
	g_object_ref_sink (_tmp3_);
	_g_object_unref0 (self->priv->text_label);
	self->priv->text_label = _tmp3_;
	_tmp4_ = self->priv->text_label;
	gtk_label_set_use_markup (_tmp4_, TRUE);
	_tmp5_ = self->priv->text_label;
	gtk_widget_set_hexpand ((GtkWidget*) _tmp5_, TRUE);
	_tmp6_ = self->priv->text_label;
	gtk_widget_set_halign ((GtkWidget*) _tmp6_, GTK_ALIGN_START);
	_tmp7_ = self->priv->text_label;
	gtk_container_add ((GtkContainer*) hbox, (GtkWidget*) _tmp7_);
	_tmp8_ = text;
	dash_button_set_text (self, _tmp8_);
	_tmp9_ = g_build_filename (PKGDATADIR, "arrow_right.png", NULL, NULL);
	path = _tmp9_;
	{
		GdkPixbuf* pixbuf = NULL;
		GdkPixbuf* _tmp10_ = NULL;
		CachedImage* image = NULL;
		CachedImage* _tmp11_ = NULL;
		CachedImage* _tmp12_ = NULL;
		CachedImage* _tmp13_ = NULL;
		_tmp10_ = gdk_pixbuf_new_from_file (path, &_inner_error_);
		pixbuf = _tmp10_;
		if (_inner_error_ != NULL) {
			goto __catch3_g_error;
		}
		_tmp11_ = cached_image_new (pixbuf);
		g_object_ref_sink (_tmp11_);
		image = _tmp11_;
		_tmp12_ = image;
		gtk_widget_set_valign ((GtkWidget*) _tmp12_, GTK_ALIGN_CENTER);
		_tmp13_ = image;
		gtk_container_add ((GtkContainer*) hbox, (GtkWidget*) _tmp13_);
		_g_object_unref0 (image);
		_g_object_unref0 (pixbuf);
	}
	goto __finally3;
	__catch3_g_error:
	{
		GError* e = NULL;
		GError* _tmp14_ = NULL;
		const gchar* _tmp15_ = NULL;
		e = _inner_error_;
		_inner_error_ = NULL;
		_tmp14_ = e;
		_tmp15_ = _tmp14_->message;
		g_debug ("dash-button.vala:61: Error loading image %s: %s", path, _tmp15_);
		_g_error_free0 (e);
	}
	__finally3:
	if (_inner_error_ != NULL) {
		_g_free0 (path);
		_g_object_unref0 (hbox);
		g_critical ("file %s: line %d: uncaught error: %s (%s, %d)", __FILE__, __LINE__, _inner_error_->message, g_quark_to_string (_inner_error_->domain), _inner_error_->code);
		g_clear_error (&_inner_error_);
		return NULL;
	}
	gtk_widget_show_all ((GtkWidget*) hbox);
	gtk_container_add ((GtkContainer*) self, (GtkWidget*) hbox);
	{
		GtkCssProvider* style = NULL;
		GtkCssProvider* _tmp16_ = NULL;
		GtkStyleContext* _tmp17_ = NULL;
		_tmp16_ = gtk_css_provider_new ();
		style = _tmp16_;
		gtk_css_provider_load_from_data (style, "* {padding: 6px 8px 6px 8px;\n" \
"                                      -GtkWidget-focus-line-width: 0px" \
";\n" \
"                                     }", (gssize) (-1), &_inner_error_);
		if (_inner_error_ != NULL) {
			_g_object_unref0 (style);
			goto __catch4_g_error;
		}
		_tmp17_ = gtk_widget_get_style_context ((GtkWidget*) self);
		gtk_style_context_add_provider (_tmp17_, (GtkStyleProvider*) style, (guint) GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
		_g_object_unref0 (style);
	}
	goto __finally4;
	__catch4_g_error:
	{
		GError* e = NULL;
		GError* _tmp18_ = NULL;
		const gchar* _tmp19_ = NULL;
		e = _inner_error_;
		_inner_error_ = NULL;
		_tmp18_ = e;
		_tmp19_ = _tmp18_->message;
		g_debug ("dash-button.vala:77: Internal error loading session chooser style: %s", _tmp19_);
		_g_error_free0 (e);
	}
	__finally4:
	if (_inner_error_ != NULL) {
		_g_free0 (path);
		_g_object_unref0 (hbox);
		g_critical ("file %s: line %d: uncaught error: %s (%s, %d)", __FILE__, __LINE__, _inner_error_->message, g_quark_to_string (_inner_error_->domain), _inner_error_->code);
		g_clear_error (&_inner_error_);
		return NULL;
	}
	_g_free0 (path);
	_g_object_unref0 (hbox);
	return self;
}


DashButton* dash_button_new (const gchar* text) {
	return dash_button_construct (TYPE_DASH_BUTTON, text);
}


static gboolean dash_button_real_draw (GtkWidget* base, cairo_t* c) {
	DashButton * self;
	gboolean result = FALSE;
	cairo_t* _tmp0_ = NULL;
	cairo_t* _tmp1_ = NULL;
	cairo_t* _tmp2_ = NULL;
	cairo_t* _tmp3_ = NULL;
	FadeTracker* _tmp4_ = NULL;
	FadeTracker* _tmp5_ = NULL;
	gdouble _tmp6_ = 0.0;
	gdouble _tmp7_ = 0.0;
	self = (DashButton*) base;
	g_return_val_if_fail (c != NULL, FALSE);
	_tmp0_ = c;
	cairo_push_group (_tmp0_);
	_tmp1_ = c;
	GTK_WIDGET_CLASS (dash_button_parent_class)->draw ((GtkWidget*) G_TYPE_CHECK_INSTANCE_CAST (self, TYPE_FLAT_BUTTON, FlatButton), _tmp1_);
	_tmp2_ = c;
	cairo_pop_group_to_source (_tmp2_);
	_tmp3_ = c;
	_tmp4_ = fadable_get_fade_tracker ((Fadable*) self);
	_tmp5_ = _tmp4_;
	_tmp6_ = fade_tracker_get_alpha (_tmp5_);
	_tmp7_ = _tmp6_;
	cairo_paint_with_alpha (_tmp3_, _tmp7_);
	result = FALSE;
	return result;
}


static FadeTracker* dash_button_real_get_fade_tracker (Fadable* base) {
	FadeTracker* result;
	DashButton* self;
	FadeTracker* _tmp0_ = NULL;
	self = (DashButton*) base;
	_tmp0_ = self->priv->_fade_tracker;
	result = _tmp0_;
	return result;
}


static gpointer _g_object_ref0 (gpointer self) {
	return self ? g_object_ref (self) : NULL;
}


static void dash_button_real_set_fade_tracker (Fadable* base, FadeTracker* value) {
	DashButton* self;
	FadeTracker* _tmp0_ = NULL;
	FadeTracker* _tmp1_ = NULL;
	self = (DashButton*) base;
	_tmp0_ = value;
	_tmp1_ = _g_object_ref0 (_tmp0_);
	_g_object_unref0 (self->priv->_fade_tracker);
	self->priv->_fade_tracker = _tmp1_;
	g_object_notify ((GObject *) self, "fade-tracker");
}


const gchar* dash_button_get_text (DashButton* self) {
	const gchar* result;
	const gchar* _tmp0_ = NULL;
	g_return_val_if_fail (self != NULL, NULL);
	_tmp0_ = self->priv->_text;
	result = _tmp0_;
	return result;
}


void dash_button_set_text (DashButton* self, const gchar* value) {
	const gchar* _tmp0_ = NULL;
	gchar* _tmp1_ = NULL;
	GtkLabel* _tmp2_ = NULL;
	const gchar* _tmp3_ = NULL;
	gchar* _tmp4_ = NULL;
	gchar* _tmp5_ = NULL;
	g_return_if_fail (self != NULL);
	_tmp0_ = value;
	_tmp1_ = g_strdup (_tmp0_);
	_g_free0 (self->priv->_text);
	self->priv->_text = _tmp1_;
	_tmp2_ = self->priv->text_label;
	_tmp3_ = value;
	_tmp4_ = g_strdup_printf ("<span font=\"Ubuntu 13\">%s</span>", _tmp3_);
	_tmp5_ = _tmp4_;
	gtk_label_set_markup (_tmp2_, _tmp5_);
	_g_free0 (_tmp5_);
	g_object_notify ((GObject *) self, "text");
}


static void dash_button_class_init (DashButtonClass * klass) {
	dash_button_parent_class = g_type_class_peek_parent (klass);
	g_type_class_add_private (klass, sizeof (DashButtonPrivate));
	GTK_WIDGET_CLASS (klass)->draw = dash_button_real_draw;
	G_OBJECT_CLASS (klass)->get_property = _vala_dash_button_get_property;
	G_OBJECT_CLASS (klass)->set_property = _vala_dash_button_set_property;
	G_OBJECT_CLASS (klass)->finalize = dash_button_finalize;
	g_object_class_install_property (G_OBJECT_CLASS (klass), DASH_BUTTON_FADE_TRACKER, g_param_spec_object ("fade-tracker", "fade-tracker", "fade-tracker", TYPE_FADE_TRACKER, G_PARAM_STATIC_NAME | G_PARAM_STATIC_NICK | G_PARAM_STATIC_BLURB | G_PARAM_READABLE | G_PARAM_WRITABLE));
	g_object_class_install_property (G_OBJECT_CLASS (klass), DASH_BUTTON_TEXT, g_param_spec_string ("text", "text", "text", NULL, G_PARAM_STATIC_NAME | G_PARAM_STATIC_NICK | G_PARAM_STATIC_BLURB | G_PARAM_READABLE | G_PARAM_WRITABLE));
}


static void dash_button_fadable_interface_init (FadableIface * iface) {
	dash_button_fadable_parent_iface = g_type_interface_peek_parent (iface);
	iface->get_fade_tracker = dash_button_real_get_fade_tracker;
	iface->set_fade_tracker = dash_button_real_set_fade_tracker;
}


static void dash_button_instance_init (DashButton * self) {
	gchar* _tmp0_ = NULL;
	self->priv = DASH_BUTTON_GET_PRIVATE (self);
	_tmp0_ = g_strdup ("");
	self->priv->_text = _tmp0_;
}


static void dash_button_finalize (GObject* obj) {
	DashButton * self;
	self = G_TYPE_CHECK_INSTANCE_CAST (obj, TYPE_DASH_BUTTON, DashButton);
	_g_object_unref0 (self->priv->_fade_tracker);
	_g_object_unref0 (self->priv->text_label);
	_g_free0 (self->priv->_text);
	G_OBJECT_CLASS (dash_button_parent_class)->finalize (obj);
}


GType dash_button_get_type (void) {
	static volatile gsize dash_button_type_id__volatile = 0;
	if (g_once_init_enter (&dash_button_type_id__volatile)) {
		static const GTypeInfo g_define_type_info = { sizeof (DashButtonClass), (GBaseInitFunc) NULL, (GBaseFinalizeFunc) NULL, (GClassInitFunc) dash_button_class_init, (GClassFinalizeFunc) NULL, NULL, sizeof (DashButton), 0, (GInstanceInitFunc) dash_button_instance_init, NULL };
		static const GInterfaceInfo fadable_info = { (GInterfaceInitFunc) dash_button_fadable_interface_init, (GInterfaceFinalizeFunc) NULL, NULL};
		GType dash_button_type_id;
		dash_button_type_id = g_type_register_static (TYPE_FLAT_BUTTON, "DashButton", &g_define_type_info, 0);
		g_type_add_interface_static (dash_button_type_id, TYPE_FADABLE, &fadable_info);
		g_once_init_leave (&dash_button_type_id__volatile, dash_button_type_id);
	}
	return dash_button_type_id__volatile;
}


static void _vala_dash_button_get_property (GObject * object, guint property_id, GValue * value, GParamSpec * pspec) {
	DashButton * self;
	self = G_TYPE_CHECK_INSTANCE_CAST (object, TYPE_DASH_BUTTON, DashButton);
	switch (property_id) {
		case DASH_BUTTON_FADE_TRACKER:
		g_value_set_object (value, fadable_get_fade_tracker ((Fadable*) self));
		break;
		case DASH_BUTTON_TEXT:
		g_value_set_string (value, dash_button_get_text (self));
		break;
		default:
		G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
		break;
	}
}


static void _vala_dash_button_set_property (GObject * object, guint property_id, const GValue * value, GParamSpec * pspec) {
	DashButton * self;
	self = G_TYPE_CHECK_INSTANCE_CAST (object, TYPE_DASH_BUTTON, DashButton);
	switch (property_id) {
		case DASH_BUTTON_FADE_TRACKER:
		fadable_set_fade_tracker ((Fadable*) self, g_value_get_object (value));
		break;
		case DASH_BUTTON_TEXT:
		dash_button_set_text (self, g_value_get_string (value));
		break;
		default:
		G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
		break;
	}
}



