/*************************************************************************/
/*  alert_panel.mm                                                       */
/*************************************************************************/

#include "alert_panel.h"

#include "platform/osx/os_osx.h"

#include <AppKit/AppKit.h>

void AlertPanel::_bind_methods() {
	ClassDB::bind_method(D_METHOD("clear_buttons"), &AlertPanel::clear_buttons);
	ClassDB::bind_method(D_METHOD("add_button", "button"), &AlertPanel::add_button);

	ClassDB::bind_method(D_METHOD("set_buttons", "buttons"), &AlertPanel::set_buttons);
	ClassDB::bind_method(D_METHOD("get_buttons"), &AlertPanel::get_buttons);

	ClassDB::bind_method(D_METHOD("set_mode", "mode"), &AlertPanel::set_mode);
	ClassDB::bind_method(D_METHOD("get_mode"), &AlertPanel::get_mode);

	ClassDB::bind_method(D_METHOD("set_suppression", "suppression"), &AlertPanel::set_suppression);
	ClassDB::bind_method(D_METHOD("get_suppression"), &AlertPanel::get_suppression);

	ClassDB::bind_method(D_METHOD("set_suppression_text", "suppression_text"), &AlertPanel::set_suppression_text);
	ClassDB::bind_method(D_METHOD("get_suppression_text"), &AlertPanel::get_suppression_text);

	ClassDB::bind_method(D_METHOD("get_panel_icon"), &AlertPanel::get_panel_icon);
	ClassDB::bind_method(D_METHOD("set_panel_icon", "icon"), &AlertPanel::set_panel_icon);

	ClassDB::bind_method(D_METHOD("get_info"), &AlertPanel::get_info);
	ClassDB::bind_method(D_METHOD("set_info", "info"), &AlertPanel::set_info);

	ClassDB::bind_method(D_METHOD("get_message"), &AlertPanel::get_message);
	ClassDB::bind_method(D_METHOD("set_message", "message"), &AlertPanel::set_message);

	ClassDB::bind_method(D_METHOD("popup"), &AlertPanel::popup);

#if (VERSION_MAJOR == 3)
	ADD_PROPERTY(PropertyInfo(Variant::POOL_STRING_ARRAY, "buttons"), "set_buttons", "get_buttons");
#else
	ADD_PROPERTY(PropertyInfo(Variant::PACKED_STRING_ARRAY, "buttons"), "set_buttons", "get_buttons");
#endif
	ADD_PROPERTY(PropertyInfo(Variant::INT, "mode", PROPERTY_HINT_ENUM, "Critical,Informational,Warning"), "set_mode", "get_mode");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "suppression"), "set_suppression", "get_suppression");
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "suppression_text"), "set_suppression_text", "get_suppression_text");
	ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "panel_icon", PROPERTY_HINT_RESOURCE_TYPE, "Image"), "set_panel_icon", "get_panel_icon");
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "info"), "set_info", "get_info");
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "message"), "set_message", "get_message");

	ADD_SIGNAL(MethodInfo("button_pressed", PropertyInfo(Variant::INT, "button_num"), PropertyInfo(Variant::BOOL, "suppress")));

	BIND_ENUM_CONSTANT(MODE_CRIT);
	BIND_ENUM_CONSTANT(MODE_INFO);
	BIND_ENUM_CONSTANT(MODE_WARN);
}

void AlertPanel::clear_buttons() {
	buttons.clear();
}

void AlertPanel::add_button(const String &p_button) {
	buttons.push_back(p_button);
}

void AlertPanel::set_buttons(const Vector<String> &p_buttons) {
	buttons = p_buttons;
}

Vector<String> AlertPanel::get_buttons() const {
	return buttons;
}

void AlertPanel::set_mode(Mode p_mode) {
	ERR_FAIL_INDEX((int)p_mode, 3);
	mode = p_mode;
}

AlertPanel::Mode AlertPanel::get_mode() const {
	return mode;
}

void AlertPanel::set_suppression(bool p_suppression) {
	suppression = p_suppression;
}

bool AlertPanel::get_suppression() const {
	return suppression;
}

String AlertPanel::get_suppression_text() const {
	return suppression_text;
}

void AlertPanel::set_suppression_text(const String &p_suppression_text) {
	suppression_text = p_suppression_text;
}

Ref<Image> AlertPanel::get_panel_icon() const {
	return icon;
}

void AlertPanel::set_panel_icon(const Ref<Image> &p_icon) {
	if (p_icon.is_valid()) {
		icon = p_icon->duplicate();
		icon->convert(Image::FORMAT_RGBA8);
	} else {
		icon = Ref<Image>();
	}
}

String AlertPanel::get_info() const {
	return info;
}

void AlertPanel::set_info(const String &p_info) {
	info = p_info;
}

String AlertPanel::get_message() const {
	return message;
}

void AlertPanel::set_message(const String &p_message) {
	message = p_message;
}

void AlertPanel::popup() {
	NSAlert *panel = [[NSAlert alloc] init];
	NSString *ns_info = [NSString stringWithUTF8String:info.utf8().get_data()];
	NSString *ns_message = [NSString stringWithUTF8String:message.utf8().get_data()];
	NSString *ns_suppression = [NSString stringWithUTF8String:suppression_text.utf8().get_data()];

	if (icon.is_valid()) {
		NSBitmapImageRep *imgrep = [[[NSBitmapImageRep alloc]
								initWithBitmapDataPlanes:NULL
								pixelsWide:icon->get_width()
								pixelsHigh:icon->get_height()
								bitsPerSample:8
								samplesPerPixel:4
								hasAlpha:YES
								isPlanar:NO
								colorSpaceName:NSDeviceRGBColorSpace
								bytesPerRow:icon->get_width() * 4
								bitsPerPixel:32] autorelease];

		ERR_FAIL_COND(imgrep == nil);
		uint8_t *pixels = [imgrep bitmapData];

		int len = icon->get_width() * icon->get_height();
	
#if (VERSION_MAJOR == 3)
		PoolVector<uint8_t> data = icon->get_data();
		PoolVector<uint8_t>::Read r = data.read();
#else
		const uint8_t *r = icon->get_data().ptr();
#endif

		for (int i = 0; i < len; i++) {
			uint8_t alpha = r[i * 4 + 3];
			pixels[i * 4 + 0] = (uint8_t)(((uint16_t)r[i * 4 + 0] * alpha) / 255);
			pixels[i * 4 + 1] = (uint8_t)(((uint16_t)r[i * 4 + 1] * alpha) / 255);
			pixels[i * 4 + 2] = (uint8_t)(((uint16_t)r[i * 4 + 2] * alpha) / 255);
			pixels[i * 4 + 3] = alpha;
		}

		NSImage *nsimg = [[[NSImage alloc] initWithSize:NSMakeSize(icon->get_width(), icon->get_height())] autorelease];
		ERR_FAIL_COND(nsimg == nil);
		[nsimg addRepresentation:imgrep];

		[panel setIcon:nsimg];
	}

	for (int i = 0; i < buttons.size(); i++) {
		NSString *ns_button = [NSString stringWithUTF8String:buttons[i].utf8().get_data()];
		[panel addButtonWithTitle:ns_button];
	}
	[panel setShowsSuppressionButton:suppression];
	[panel.suppressionButton setTitle:ns_suppression];
	[panel setMessageText:ns_message];
	[panel setInformativeText:ns_info];
	if (mode == MODE_CRIT) {
		[panel setAlertStyle:NSAlertStyleCritical];
	} else if (mode == MODE_INFO) {
		[panel setAlertStyle:NSAlertStyleInformational];
	} else if (mode == MODE_WARN) {
		[panel setAlertStyle:NSAlertStyleWarning];
	}

	[panel beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow] completionHandler:^(NSInteger ret) {
		if (ret == NSAlertFirstButtonReturn) {
			this->emit_signal("button_pressed", int64_t(0), (panel.suppressionButton.state == NSControlStateValueOn));
		} else if (ret == NSAlertSecondButtonReturn) {
			this->emit_signal("button_pressed", int64_t(1), (panel.suppressionButton.state == NSControlStateValueOn));
		} else if (ret == NSAlertThirdButtonReturn) {
			this->emit_signal("button_pressed", int64_t(2), (panel.suppressionButton.state == NSControlStateValueOn));
		} else {
			this->emit_signal("button_pressed", int64_t(3 + (ret - NSAlertThirdButtonReturn)), (panel.suppressionButton.state == NSControlStateValueOn));
		}
	}];

	[panel release];
}

String AlertPanel::get_configuration_warning() const {
	if (is_visible_in_tree()) {
		return TTR("Popups will hide by default unless you call popup() function.");
	}
	return String();
}

AlertPanel::AlertPanel() {
	message = "";
	info = "";
	suppression_text = "Do not show this message again.";
	buttons.push_back("OK");
	
	mode = MODE_INFO;
	suppression = false;
	hide();
}
