# -*- Mode: Automake; indent-tabs-mode: t; tab-width: 4 -*-

xgreeterdir = $(datarootdir)/xgreeters
dist_xgreeter_DATA = kylin-greeter.desktop

dist_pkgdata_DATA = \
	a11y.svg \
	active.png \
	arrow_left.png \
	arrow_left_active.png \
	arrow_left_prelight.png \
	arrow_right.png \
	arrow_right_en.png \
	arrow_right_active.png \
	arrow_right_active_en.png \
	arrow_right_prelight.png \
	arrow_right_prelight_en.png \
	arrow-down_can_click.png \
	arrow-down_cannot_click.png \
	arrow-up_can_click.png \
	arrow-up_cannot_click.png \
	background.png \
	cof.png \
	logo.png \
	dialog_close.png \
	dialog_close_highlight.png \
	dialog_close_press.png \
	default_face.png \
	gnome_badge.png \
	hibernate_highlight.png \
	hibernate.png \
	kde_badge.png \
	message.png \
	recovery_console_badge.png \
	remote_login_help.png \
	restart_highlight.png \
	restart.png \
	shadow.png \
	show_password.png \
	hide_password.png \
	shutdown_highlight.png \
	shutdown.png \
	suspend_highlight.png \
	suspend.png \
	switcher_corner.png \
	switcher_left.png \
	switcher_top.png \
	keyboardbutton.png \
	keyboardbutton_active.png \
	shutdownbutton.png \
	ubuntu_badge.png \
	ukui_badge.png \
	unknown_badge.png

@GSETTINGS_RULES@
gsettings_SCHEMAS = com.kylin.kylin-greeter.gschema.xml

dist_man1_MANS = kylin-greeter.1

EXTRA_DIST = \
	$(gsettings_SCHEMAS)

DISTCLEANFILES = \
	Makefile.in
