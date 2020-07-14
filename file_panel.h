/*************************************************************************/
/*  file_panel.h                                                         */
/*************************************************************************/

#ifndef FILE_PANEL_H
#define FILE_PANEL_H

#include "scene/gui/control.h"
#include "core/version_generated.gen.h"

class FilePanel : public Control {
	GDCLASS(FilePanel, Control);

public:
	enum Mode {
		MODE_OPEN_FILE,
		MODE_OPEN_FILES,
		MODE_OPEN_DIR,
		MODE_SAVE_FILE
	};

private:
	String file_name;
	String current_dir;
	Vector<String> filters;
	Mode mode;
	bool show_hidden;

protected:
	static void _bind_methods();

public:
	void clear_filters();
	void add_filter(const String &p_filter);
	void set_filters(const Vector<String> &p_filters);
	Vector<String> get_filters() const;

	void set_mode(Mode p_mode);
	Mode get_mode() const;

	String get_current_dir() const;
	void set_current_dir(const String &p_dir);

	void set_show_hidden_files(bool p_show);
	bool get_show_hidden_files() const;

	String get_current_file() const;
	void set_current_file(const String &p_file);

	virtual void popup();

#if (VERSION_MAJOR == 3)
	virtual String get_configuration_warning() const;
#else
	virtual String get_configuration_warning() const override;
#endif

	FilePanel();
};

VARIANT_ENUM_CAST(FilePanel::Mode);

#endif
