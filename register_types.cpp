/*************************************************************************/
/*  register_types.cpp                                                   */
/*************************************************************************/

#include "register_types.h"
#include "alert_panel.h"
#include "file_panel.h"

#include "core/class_db.h"

void register_mac_file_panels_types() {
	ClassDB::register_class<AlertPanel>();
	ClassDB::register_class<FilePanel>();
}

void unregister_mac_file_panels_types() {
	//NOP
}
