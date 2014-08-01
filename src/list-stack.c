/* list-stack.c generated by valac 0.22.1, the Vala compiler
 * generated from list-stack.vala, do not modify */

/* -*- Mode: Vala; indent-tabs-mode: nil; tab-width: 4 -*-
 *
 * Copyright (C) 2011,2012 Canonical Ltd
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
 * Authored by: Michael Terry <michael.terry@canonical.com>
 */

#include <glib.h>
#include <glib-object.h>
#include <gtk/gtk.h>
#include <cairo.h>
#include <stdlib.h>
#include <string.h>
#include <float.h>
#include <math.h>
#include <lightdm.h>


#define TYPE_LIST_STACK (list_stack_get_type ())
#define LIST_STACK(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_LIST_STACK, ListStack))
#define LIST_STACK_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_LIST_STACK, ListStackClass))
#define IS_LIST_STACK(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_LIST_STACK))
#define IS_LIST_STACK_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_LIST_STACK))
#define LIST_STACK_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_LIST_STACK, ListStackClass))

typedef struct _ListStack ListStack;
typedef struct _ListStackClass ListStackClass;
typedef struct _ListStackPrivate ListStackPrivate;

#define TYPE_FADABLE_BOX (fadable_box_get_type ())
#define FADABLE_BOX(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_FADABLE_BOX, FadableBox))
#define FADABLE_BOX_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_FADABLE_BOX, FadableBoxClass))
#define IS_FADABLE_BOX(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_FADABLE_BOX))
#define IS_FADABLE_BOX_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_FADABLE_BOX))
#define FADABLE_BOX_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_FADABLE_BOX, FadableBoxClass))

typedef struct _FadableBox FadableBox;
typedef struct _FadableBoxClass FadableBoxClass;

#define TYPE_GREETER_LIST (greeter_list_get_type ())
#define GREETER_LIST(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_GREETER_LIST, GreeterList))
#define GREETER_LIST_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_GREETER_LIST, GreeterListClass))
#define IS_GREETER_LIST(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_GREETER_LIST))
#define IS_GREETER_LIST_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_GREETER_LIST))
#define GREETER_LIST_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_GREETER_LIST, GreeterListClass))

typedef struct _GreeterList GreeterList;
typedef struct _GreeterListClass GreeterListClass;
#define _g_list_free0(var) ((var == NULL) ? NULL : (var = (g_list_free (var), NULL)))

#define TYPE_PROMPT_BOX (prompt_box_get_type ())
#define PROMPT_BOX(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_PROMPT_BOX, PromptBox))
#define PROMPT_BOX_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_PROMPT_BOX, PromptBoxClass))
#define IS_PROMPT_BOX(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_PROMPT_BOX))
#define IS_PROMPT_BOX_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_PROMPT_BOX))
#define PROMPT_BOX_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_PROMPT_BOX, PromptBoxClass))

typedef struct _PromptBox PromptBox;
typedef struct _PromptBoxClass PromptBoxClass;

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
typedef struct _FadableBoxPrivate FadableBoxPrivate;
typedef struct _GreeterListPrivate GreeterListPrivate;

#define TYPE_DASH_BOX (dash_box_get_type ())
#define DASH_BOX(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_DASH_BOX, DashBox))
#define DASH_BOX_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_DASH_BOX, DashBoxClass))
#define IS_DASH_BOX(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_DASH_BOX))
#define IS_DASH_BOX_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_DASH_BOX))
#define DASH_BOX_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_DASH_BOX, DashBoxClass))

typedef struct _DashBox DashBox;
typedef struct _DashBoxClass DashBoxClass;

#define GREETER_LIST_TYPE_MODE (greeter_list_mode_get_type ())
#define _g_object_unref0(var) ((var == NULL) ? NULL : (var = (g_object_unref (var), NULL)))

struct _ListStack {
	GtkFixed parent_instance;
	ListStackPrivate * priv;
};

struct _ListStackClass {
	GtkFixedClass parent_class;
};

struct _ListStackPrivate {
	gint width;
};

struct _FadableIface {
	GTypeInterface parent_iface;
	FadeTracker* (*get_fade_tracker) (Fadable* self);
	void (*set_fade_tracker) (Fadable* self, FadeTracker* value);
};

struct _FadableBox {
	GtkEventBox parent_instance;
	FadableBoxPrivate * priv;
};

struct _FadableBoxClass {
	GtkEventBoxClass parent_class;
	void (*draw_full_alpha) (FadableBox* self, cairo_t* c);
};

typedef enum  {
	GREETER_LIST_MODE_ENTRY,
	GREETER_LIST_MODE_SCROLLING
} GreeterListMode;

struct _GreeterList {
	FadableBox parent_instance;
	GreeterListPrivate * priv;
	gchar* greeter_authenticating_user;
	gboolean _always_show_manual;
	GList* entries;
	DashBox* greeter_box;
	GreeterListMode mode;
	gboolean will_clear;
	gboolean prompted;
	gboolean unacknowledged_messages;
	gchar* test_username;
	gboolean test_is_authenticated;
};

struct _GreeterListClass {
	FadableBoxClass parent_class;
	gchar* (*get_selected_id) (GreeterList* self);
	void (*focus_prompt) (GreeterList* self);
	void (*show_authenticated) (GreeterList* self, gboolean successful);
	void (*insert_entry) (GreeterList* self, PromptBox* entry);
	void (*add_manual_entry) (GreeterList* self);
	gint (*get_position_y) (GreeterList* self, gdouble position);
	void (*setup_prompt_box) (GreeterList* self, gboolean fade);
	void (*show_prompt_cb) (GreeterList* self, const gchar* text, LightDMPromptType type);
	void (*authentication_complete_cb) (GreeterList* self);
	void (*start_authentication) (GreeterList* self);
	gchar* (*get_lightdm_session) (GreeterList* self);
	void (*test_start_authentication) (GreeterList* self);
};


static gpointer list_stack_parent_class = NULL;

GType list_stack_get_type (void) G_GNUC_CONST;
#define LIST_STACK_GET_PRIVATE(o) (G_TYPE_INSTANCE_GET_PRIVATE ((o), TYPE_LIST_STACK, ListStackPrivate))
enum  {
	LIST_STACK_DUMMY_PROPERTY,
	LIST_STACK_NUM_CHILDREN
};
GType fadable_box_get_type (void) G_GNUC_CONST;
GType greeter_list_get_type (void) G_GNUC_CONST;
GreeterList* list_stack_top (ListStack* self);
void list_stack_push (ListStack* self, GreeterList* pushed);
void greeter_list_set_start_scrolling (GreeterList* self, gboolean value);
GType prompt_box_get_type (void) G_GNUC_CONST;
PromptBox* greeter_list_get_selected_entry (GreeterList* self);
void prompt_box_reset_state (PromptBox* self);
GType fade_tracker_get_type (void) G_GNUC_CONST;
GType fadable_get_type (void) G_GNUC_CONST;
GType dash_box_get_type (void) G_GNUC_CONST;
GType greeter_list_mode_get_type (void) G_GNUC_CONST;
void dash_box_push (DashBox* self, GreeterList* l);
void list_stack_pop (ListStack* self);
void dash_box_pop (DashBox* self);
static void list_stack_real_size_allocate (GtkWidget* base, GtkAllocation* allocation);
static void list_stack_real_get_preferred_width (GtkWidget* base, gint* min, gint* nat);
ListStack* list_stack_new (void);
ListStack* list_stack_construct (GType object_type);
guint list_stack_get_num_children (ListStack* self);
static GObject * list_stack_constructor (GType type, guint n_construct_properties, GObjectConstructParam * construct_properties);
#define grid_size 40
#define GREETER_LIST_BOX_WIDTH 8
static void list_stack_finalize (GObject* obj);
static void _vala_list_stack_get_property (GObject * object, guint property_id, GValue * value, GParamSpec * pspec);


static gpointer _g_object_ref0 (gpointer self) {
	return self ? g_object_ref (self) : NULL;
}


GreeterList* list_stack_top (ListStack* self) {
	GreeterList* result = NULL;
	GList* children = NULL;
	GList* _tmp0_ = NULL;
	GList* _tmp1_ = NULL;
	g_return_val_if_fail (self != NULL, NULL);
	_tmp0_ = gtk_container_get_children ((GtkContainer*) self);
	children = _tmp0_;
	_tmp1_ = children;
	if (_tmp1_ == NULL) {
		result = NULL;
		_g_list_free0 (children);
		return result;
	} else {
		GList* _tmp2_ = NULL;
		GList* _tmp3_ = NULL;
		gconstpointer _tmp4_ = NULL;
		GtkWidget* _tmp5_ = NULL;
		GreeterList* _tmp6_ = NULL;
		_tmp2_ = children;
		_tmp3_ = g_list_last (_tmp2_);
		_tmp4_ = _tmp3_->data;
		_tmp5_ = (GtkWidget*) _tmp4_;
		_tmp6_ = _g_object_ref0 (G_TYPE_CHECK_INSTANCE_TYPE (_tmp5_, TYPE_GREETER_LIST) ? ((GreeterList*) _tmp5_) : NULL);
		result = _tmp6_;
		_g_list_free0 (children);
		return result;
	}
	_g_list_free0 (children);
}


void list_stack_push (ListStack* self, GreeterList* pushed) {
	GreeterList* _tmp0_ = NULL;
	GList* children = NULL;
	GList* _tmp1_ = NULL;
	GreeterList* _tmp2_ = NULL;
	GreeterList* _tmp3_ = NULL;
	gint _tmp4_ = 0;
	GreeterList* _tmp5_ = NULL;
	GList* _tmp6_ = NULL;
	g_return_if_fail (self != NULL);
	g_return_if_fail (pushed != NULL);
	_tmp0_ = pushed;
	g_return_if_fail (_tmp0_ != NULL);
	_tmp1_ = gtk_container_get_children ((GtkContainer*) self);
	children = _tmp1_;
	_tmp2_ = pushed;
	greeter_list_set_start_scrolling (_tmp2_, FALSE);
	_tmp3_ = pushed;
	_tmp4_ = self->priv->width;
	gtk_widget_set_size_request ((GtkWidget*) _tmp3_, _tmp4_, -1);
	_tmp5_ = pushed;
	gtk_container_add ((GtkContainer*) self, (GtkWidget*) _tmp5_);
	_tmp6_ = children;
	if (_tmp6_ != NULL) {
		GreeterList* current = NULL;
		GList* _tmp7_ = NULL;
		GList* _tmp8_ = NULL;
		gconstpointer _tmp9_ = NULL;
		GtkWidget* _tmp10_ = NULL;
		GreeterList* _tmp11_ = NULL;
		GreeterList* _tmp12_ = NULL;
		PromptBox* _tmp13_ = NULL;
		PromptBox* _tmp14_ = NULL;
		GreeterList* _tmp15_ = NULL;
		DashBox* _tmp16_ = NULL;
		GreeterList* _tmp17_ = NULL;
		_tmp7_ = children;
		_tmp8_ = g_list_last (_tmp7_);
		_tmp9_ = _tmp8_->data;
		_tmp10_ = (GtkWidget*) _tmp9_;
		_tmp11_ = _g_object_ref0 (G_TYPE_CHECK_INSTANCE_TYPE (_tmp10_, TYPE_GREETER_LIST) ? ((GreeterList*) _tmp10_) : NULL);
		current = _tmp11_;
		_tmp12_ = current;
		_tmp13_ = greeter_list_get_selected_entry (_tmp12_);
		_tmp14_ = _tmp13_;
		prompt_box_reset_state (_tmp14_);
		_tmp15_ = current;
		_tmp16_ = _tmp15_->greeter_box;
		_tmp17_ = pushed;
		dash_box_push (_tmp16_, _tmp17_);
		_g_object_unref0 (current);
	}
	_g_list_free0 (children);
}


void list_stack_pop (ListStack* self) {
	GList* children = NULL;
	GList* _tmp0_ = NULL;
	GList* _tmp1_ = NULL;
	GList* prev = NULL;
	GList* _tmp2_ = NULL;
	GList* _tmp3_ = NULL;
	GList* _tmp4_ = NULL;
	GList* _tmp5_ = NULL;
	g_return_if_fail (self != NULL);
	_tmp0_ = gtk_container_get_children ((GtkContainer*) self);
	children = _tmp0_;
	_tmp1_ = children;
	g_return_if_fail (_tmp1_ != NULL);
	_tmp2_ = children;
	_tmp3_ = g_list_last (_tmp2_);
	_tmp4_ = _tmp3_->prev;
	prev = _tmp4_;
	_tmp5_ = prev;
	if (_tmp5_ != NULL) {
		GList* _tmp6_ = NULL;
		gconstpointer _tmp7_ = NULL;
		GtkWidget* _tmp8_ = NULL;
		DashBox* _tmp9_ = NULL;
		_tmp6_ = prev;
		_tmp7_ = _tmp6_->data;
		_tmp8_ = (GtkWidget*) _tmp7_;
		_tmp9_ = (G_TYPE_CHECK_INSTANCE_TYPE (_tmp8_, TYPE_GREETER_LIST) ? ((GreeterList*) _tmp8_) : NULL)->greeter_box;
		dash_box_pop (_tmp9_);
	}
	_g_list_free0 (children);
}


static void list_stack_real_size_allocate (GtkWidget* base, GtkAllocation* allocation) {
	ListStack * self;
	GtkAllocation _tmp0_ = {0};
	GList* children = NULL;
	GList* _tmp1_ = NULL;
	GList* _tmp2_ = NULL;
	self = (ListStack*) base;
	g_return_if_fail (allocation != NULL);
	_tmp0_ = *allocation;
	GTK_WIDGET_CLASS (list_stack_parent_class)->size_allocate ((GtkWidget*) G_TYPE_CHECK_INSTANCE_CAST (self, GTK_TYPE_FIXED, GtkFixed), &_tmp0_);
	_tmp1_ = gtk_container_get_children ((GtkContainer*) self);
	children = _tmp1_;
	_tmp2_ = children;
	{
		GList* child_collection = NULL;
		GList* child_it = NULL;
		child_collection = _tmp2_;
		for (child_it = child_collection; child_it != NULL; child_it = child_it->next) {
			GtkWidget* child = NULL;
			child = (GtkWidget*) child_it->data;
			{
				GtkWidget* _tmp3_ = NULL;
				GtkAllocation _tmp4_ = {0};
				_tmp3_ = child;
				_tmp4_ = *allocation;
				gtk_widget_size_allocate (_tmp3_, &_tmp4_);
			}
		}
	}
	_g_list_free0 (children);
}


static void list_stack_real_get_preferred_width (GtkWidget* base, gint* min, gint* nat) {
	ListStack * self;
	gint _vala_min = 0;
	gint _vala_nat = 0;
	gint _tmp0_ = 0;
	gint _tmp1_ = 0;
	self = (ListStack*) base;
	_tmp0_ = self->priv->width;
	_vala_min = _tmp0_;
	_tmp1_ = self->priv->width;
	_vala_nat = _tmp1_;
	if (min) {
		*min = _vala_min;
	}
	if (nat) {
		*nat = _vala_nat;
	}
}


ListStack* list_stack_construct (GType object_type) {
	ListStack * self = NULL;
	self = (ListStack*) g_object_new (object_type, NULL);
	return self;
}


ListStack* list_stack_new (void) {
	return list_stack_construct (TYPE_LIST_STACK);
}


guint list_stack_get_num_children (ListStack* self) {
	guint result;
	GList* children = NULL;
	GList* _tmp0_ = NULL;
	guint _tmp1_ = 0U;
	g_return_val_if_fail (self != NULL, 0U);
	_tmp0_ = gtk_container_get_children ((GtkContainer*) self);
	children = _tmp0_;
	_tmp1_ = g_list_length (children);
	result = _tmp1_;
	_g_list_free0 (children);
	return result;
}


static GObject * list_stack_constructor (GType type, guint n_construct_properties, GObjectConstructParam * construct_properties) {
	GObject * obj;
	GObjectClass * parent_class;
	ListStack * self;
	parent_class = G_OBJECT_CLASS (list_stack_parent_class);
	obj = parent_class->constructor (type, n_construct_properties, construct_properties);
	self = G_TYPE_CHECK_INSTANCE_CAST (obj, TYPE_LIST_STACK, ListStack);
	self->priv->width = grid_size * GREETER_LIST_BOX_WIDTH;
	return obj;
}


static void list_stack_class_init (ListStackClass * klass) {
	list_stack_parent_class = g_type_class_peek_parent (klass);
	g_type_class_add_private (klass, sizeof (ListStackPrivate));
	GTK_WIDGET_CLASS (klass)->size_allocate = list_stack_real_size_allocate;
	GTK_WIDGET_CLASS (klass)->get_preferred_width = list_stack_real_get_preferred_width;
	G_OBJECT_CLASS (klass)->get_property = _vala_list_stack_get_property;
	G_OBJECT_CLASS (klass)->constructor = list_stack_constructor;
	G_OBJECT_CLASS (klass)->finalize = list_stack_finalize;
	g_object_class_install_property (G_OBJECT_CLASS (klass), LIST_STACK_NUM_CHILDREN, g_param_spec_uint ("num-children", "num-children", "num-children", 0, G_MAXUINT, 0U, G_PARAM_STATIC_NAME | G_PARAM_STATIC_NICK | G_PARAM_STATIC_BLURB | G_PARAM_READABLE));
}


static void list_stack_instance_init (ListStack * self) {
	self->priv = LIST_STACK_GET_PRIVATE (self);
}


static void list_stack_finalize (GObject* obj) {
	ListStack * self;
	self = G_TYPE_CHECK_INSTANCE_CAST (obj, TYPE_LIST_STACK, ListStack);
	G_OBJECT_CLASS (list_stack_parent_class)->finalize (obj);
}


GType list_stack_get_type (void) {
	static volatile gsize list_stack_type_id__volatile = 0;
	if (g_once_init_enter (&list_stack_type_id__volatile)) {
		static const GTypeInfo g_define_type_info = { sizeof (ListStackClass), (GBaseInitFunc) NULL, (GBaseFinalizeFunc) NULL, (GClassInitFunc) list_stack_class_init, (GClassFinalizeFunc) NULL, NULL, sizeof (ListStack), 0, (GInstanceInitFunc) list_stack_instance_init, NULL };
		GType list_stack_type_id;
		list_stack_type_id = g_type_register_static (GTK_TYPE_FIXED, "ListStack", &g_define_type_info, 0);
		g_once_init_leave (&list_stack_type_id__volatile, list_stack_type_id);
	}
	return list_stack_type_id__volatile;
}


static void _vala_list_stack_get_property (GObject * object, guint property_id, GValue * value, GParamSpec * pspec) {
	ListStack * self;
	self = G_TYPE_CHECK_INSTANCE_CAST (object, TYPE_LIST_STACK, ListStack);
	switch (property_id) {
		case LIST_STACK_NUM_CHILDREN:
		g_value_set_uint (value, list_stack_get_num_children (self));
		break;
		default:
		G_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
		break;
	}
}



