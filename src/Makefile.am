# -*- Mode: Automake; indent-tabs-mode: t; tab-width: 4 -*-

sbin_PROGRAMS = kylin-greeter
noinst_PROGRAMS = logo-generator

kylin_greeter_SOURCES = \
	config.vapi \
	fixes.vapi \
	ido.vapi \
	animate-timer.vala \
	background.vala \
	cached-image.vala \
	cairo-utils.vala \
	email-autocompleter.vala \
	dash-box.vala \
	dash-button.vala \
	dash-entry.vala \
	fadable.vala \
	fadable-box.vala \
	fading-label.vala \
	flat-button.vala \
	greeter-list.vala \
	list-stack.vala \
	main-window.vala \
	menu.vala \
	prompt-box.vala \
	session-list.vala \
	remote-login-service.vala \
	settings.vala \
	settings-daemon.vala \
	shutdown-dialog.vala \
	toggle-box.vala \
	kylin-greeter.vala \
	user-list.vala \
	user-prompt-box.vala

logo_generator_SOURCES = logo-generator.vala

kylin_greeter_CFLAGS = \
	$(KYLIN_GREETER_CFLAGS) \
	-w \
	-DGNOME_DESKTOP_USE_UNSTABLE_API \
	-DGETTEXT_PACKAGE=\"$(GETTEXT_PACKAGE)\" \
	-DLOCALEDIR=\""$(localedir)"\" \
	-DVERSION=\"$(VERSION)\" \
	-DCONFIG_FILE=\""$(sysconfdir)/lightdm/kylin-greeter.conf"\" \
	-DPKGDATADIR=\""$(pkgdatadir)"\" \
	-DINDICATORDIR=\""$(INDICATORDIR)"\"

logo_generator_CFLAGS = $(kylin_greeter_CFLAGS)

kylin_greeter_VALAFLAGS = \
	--pkg posix \
	--pkg gtk+-3.0 \
	--pkg gdk-x11-3.0 \
	--pkg gio-unix-2.0 \
	--pkg x11 \
	--pkg liblightdm-gobject-1 \
	--pkg libcanberra \
	--pkg gio-2.0 \
	--pkg pixman-1 \
	--target-glib 2.32

logo_generator_VALAFLAGS = $(kylin_greeter_VALAFLAGS)

kylin_greeter_LDADD = \
	$(KYLIN_GREETER_LIBS) \
	-lm

logo_generator_LDADD = $(kylin_greeter_LDADD)

kylin_greeter_vala.stamp: $(top_srcdir)/config.h

DISTCLEANFILES = \
	Makefile.in
