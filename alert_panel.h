/*************************************************************************/
/*  alert_panel.h                                                        */
/*************************************************************************/

#ifndef ALERT_PANEL_H
#define ALERT_PANEL_H

#include "scene/gui/control.h"
#include "core/version_generated.gen.h"

class AlertPanel : public Control {
	GDCLASS(AlertPanel, Control);

public:
	enum Mode {
		MODE_CRIT,
		MODE_INFO,
		MODE_WARN
	};

private:
	Mode mode;
	Ref<Image> icon;
	String info;
	String message;
	Vector<String> buttons;
	bool suppression;
	String suppression_text;

protected:
	static void _bind_methods();

public:
	void clear_buttons();
	void add_button(const String &p_filter);
	void set_buttons(const Vector<String> &p_buttons);
	Vector<String> get_buttons() const;

	void set_mode(Mode p_mode);
	Mode get_mode() const;

	void set_suppression(bool p_suppress);
	bool get_suppression() const;

	String get_suppression_text() const;
	void set_suppression_text(const String &p_suppression_text);

	Ref<Image> get_panel_icon() const;
	void set_panel_icon(const Ref<Image> &p_icon);

	String get_info() const;
	void set_info(const String &p_info);

	String get_message() const;
	void set_message(const String &p_message);

	virtual void popup();

#if (VERSION_MAJOR == 3)
	virtual String get_configuration_warning() const;
#else
	virtual String get_configuration_warning() const override;
#endif

	AlertPanel();
};

VARIANT_ENUM_CAST(AlertPanel::Mode);

#endif
