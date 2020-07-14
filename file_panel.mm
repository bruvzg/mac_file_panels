/*************************************************************************/
/*  file_panel.mm                                                        */
/*************************************************************************/

#include "file_panel.h"

#include "platform/osx/os_osx.h"

#include <AppKit/AppKit.h>

void FilePanel::_bind_methods() {
	ClassDB::bind_method(D_METHOD("clear_filters"), &FilePanel::clear_filters);
	ClassDB::bind_method(D_METHOD("add_filter", "filter"), &FilePanel::add_filter);

	ClassDB::bind_method(D_METHOD("set_filters", "filters"), &FilePanel::set_filters);
	ClassDB::bind_method(D_METHOD("get_filters"), &FilePanel::get_filters);

	ClassDB::bind_method(D_METHOD("set_mode", "mode"), &FilePanel::set_mode);
	ClassDB::bind_method(D_METHOD("get_mode"), &FilePanel::get_mode);

	ClassDB::bind_method(D_METHOD("get_current_dir"), &FilePanel::get_current_dir);
	ClassDB::bind_method(D_METHOD("set_current_dir", "dir"), &FilePanel::set_current_dir);

	ClassDB::bind_method(D_METHOD("get_show_hidden_files"), &FilePanel::get_show_hidden_files);
	ClassDB::bind_method(D_METHOD("set_show_hidden_files", "show_hidden_files"), &FilePanel::set_show_hidden_files);

	ClassDB::bind_method(D_METHOD("get_current_file"), &FilePanel::get_current_file);
	ClassDB::bind_method(D_METHOD("set_current_file", "file"), &FilePanel::set_current_file);

	ClassDB::bind_method(D_METHOD("popup"), &FilePanel::popup);

#if (VERSION_MAJOR == 3)
	ADD_PROPERTY(PropertyInfo(Variant::POOL_STRING_ARRAY, "filters"), "set_filters", "get_filters");
#else
	ADD_PROPERTY(PropertyInfo(Variant::PACKED_STRING_ARRAY, "filters"), "set_filters", "get_filters");
#endif
	ADD_PROPERTY(PropertyInfo(Variant::INT, "mode", PROPERTY_HINT_ENUM, "Open File,Open Files,Open Folder,Save File"), "set_mode", "get_mode");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "show_hidden_files"), "set_show_hidden_files", "get_show_hidden_files");
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "current_file"), "set_current_file", "get_current_file");
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "current_dir"), "set_current_dir", "get_current_dir");

	ADD_SIGNAL(MethodInfo("file_selected", PropertyInfo(Variant::STRING, "path")));
#if (VERSION_MAJOR == 3)
	ADD_SIGNAL(MethodInfo("files_selected", PropertyInfo(Variant::POOL_STRING_ARRAY, "paths")));
#else
	ADD_SIGNAL(MethodInfo("files_selected", PropertyInfo(Variant::PACKED_STRING_ARRAY, "paths")));
#endif
	ADD_SIGNAL(MethodInfo("dir_selected", PropertyInfo(Variant::STRING, "dir")));

	BIND_ENUM_CONSTANT(MODE_OPEN_FILE);
	BIND_ENUM_CONSTANT(MODE_OPEN_FILES);
	BIND_ENUM_CONSTANT(MODE_OPEN_DIR);
	BIND_ENUM_CONSTANT(MODE_SAVE_FILE);
}

void FilePanel::clear_filters() {
	filters.clear();
}

void FilePanel::add_filter(const String &p_filter) {
	filters.push_back(p_filter);
}

void FilePanel::set_filters(const Vector<String> &p_filters) {
	filters = p_filters;
}

Vector<String> FilePanel::get_filters() const {
	return filters;
}

void FilePanel::set_mode(Mode p_mode) {
	ERR_FAIL_INDEX((int)p_mode, 4);
	mode = p_mode;
}

FilePanel::Mode FilePanel::get_mode() const {
	return mode;
}

void FilePanel::set_show_hidden_files(bool p_show) {
	show_hidden = p_show;
}

bool FilePanel::get_show_hidden_files() const {
	return show_hidden;
}

String FilePanel::get_current_file() const {
	return file_name;
}

void FilePanel::set_current_file(const String &p_file) {
	file_name = p_file;
}

String FilePanel::get_current_dir() const {
	return current_dir;
}

void FilePanel::set_current_dir(const String &p_dir) {
	current_dir = p_dir;
}

void FilePanel::popup() {
	NSString *url = [[NSString alloc] initWithUTF8String:current_dir.utf8().get_data()];
	NSString *fileurl = [[NSString alloc] initWithUTF8String:file_name.utf8().get_data()];
	NSMutableArray *allowed_types = [[NSMutableArray alloc] init];
	bool allow_other = false;
	for (int i = 0; i < filters.size(); i++) {
		Vector<String> tokens = filters[i].split(";");
		if (tokens.size() > 0) {
			if (tokens[0].strip_edges() == "*.*") {
				allow_other = true;
			} else {
				[allowed_types addObject:[NSString stringWithUTF8String:tokens[0].replace("*.", "").strip_edges().utf8().get_data()]];
			}
		}
	}

	switch (mode) {
		case MODE_SAVE_FILE: {
			NSSavePanel *panel = [NSSavePanel savePanel];

			[panel setDirectoryURL:[NSURL fileURLWithPath:url]];
			if ([allowed_types count]) {
				[panel setAllowedFileTypes:allowed_types];
			}
			if (allow_other) {
				[panel setAllowsOtherFileTypes:YES];
			} else {
				[panel setAllowsOtherFileTypes:NO];
			}
			[panel setExtensionHidden:YES];
			[panel setCanSelectHiddenExtension:YES];
			[panel setCanCreateDirectories:YES];
			if (show_hidden) {
				[panel setShowsHiddenFiles:YES];
			} else {
				[panel setShowsHiddenFiles:NO];
			}
			if (file_name != "") {
				[panel setNameFieldStringValue:fileurl];
			}

			[panel beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow] completionHandler:^(NSInteger ret) {
				if (ret == NSModalResponseOK) {
					String url;
					url.parse_utf8([[[panel URL] path] UTF8String]);
					this->emit_signal("file_selected", url);
				}
			}];
		} break;
		case MODE_OPEN_FILE:
			[[fallthrough]];
		case MODE_OPEN_FILES:
			[[fallthrough]];
		case MODE_OPEN_DIR: {
			NSOpenPanel *panel = [NSOpenPanel openPanel];

			[panel setDirectoryURL:[NSURL fileURLWithPath:url]];
			if ([allowed_types count]) {
				[panel setAllowedFileTypes:allowed_types];
			}
			if (allow_other) {
				[panel setAllowsOtherFileTypes:YES];
			} else {
				[panel setAllowsOtherFileTypes:NO];
			}
			[panel setExtensionHidden:YES];
			[panel setCanSelectHiddenExtension:YES];
			[panel setCanCreateDirectories:YES];
			if (mode == MODE_OPEN_DIR) {
				[panel setCanChooseFiles:NO];
				[panel setCanChooseDirectories:YES];
			} else {
				[panel setCanChooseFiles:YES];
				[panel setCanChooseDirectories:NO];
			}
			if (show_hidden) {
				[panel setShowsHiddenFiles:YES];
			} else {
				[panel setShowsHiddenFiles:NO];
			}
			if (file_name != "") {
				[panel setNameFieldStringValue:fileurl];
			}

			if (mode == MODE_OPEN_FILES) {
				[panel setAllowsMultipleSelection:YES];
			} else {
				[panel setAllowsMultipleSelection:NO];
			}

			[panel beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow] completionHandler:^(NSInteger ret) {
				if (ret == NSModalResponseOK) {
					if (mode == MODE_OPEN_DIR) {
						String url;
						url.parse_utf8([[[panel URL] path] UTF8String]);
						this->emit_signal("dir_selected", url);
					} else if (mode == MODE_OPEN_FILES) {
#if (VERSION_MAJOR == 3)
						PoolVector<String> files;
#else
						Vector<String> files;
#endif
						NSArray *urls = [(NSOpenPanel*)panel URLs];
						for (NSUInteger i = 0; i != [urls count]; ++i) {
							String url;
							url.parse_utf8([[[urls objectAtIndex:i] path] UTF8String]);
							files.push_back(url);
						}
						this->emit_signal("files_selected", files);
					} else {
						String url;
						url.parse_utf8([[[panel URL] path] UTF8String]);
						this->emit_signal("file_selected", url);
					}
				}
			}];
		} break;
	}

	[allowed_types release];
	[fileurl release];
	[url release];
}

String FilePanel::get_configuration_warning() const {
	if (is_visible_in_tree()) {
		return TTR("Popups will hide by default unless you call popup() function.");
	}
	return String();
}

FilePanel::FilePanel() {
	file_name = "";
	current_dir = OS::get_singleton()->get_system_dir(OS::SYSTEM_DIR_DOCUMENTS);
	mode = MODE_SAVE_FILE;
	show_hidden = false;
	hide();
}