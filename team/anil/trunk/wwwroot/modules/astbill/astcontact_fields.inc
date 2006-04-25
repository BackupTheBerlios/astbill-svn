<?php
/**
 * Contact Fields
 *
 * Specifies any fields that are applicable for contacts.
 *
 * @version 1.1
 * @author  LatPro Inc (George)
 */

function astcontact_fields() {
	$fields = astcontact_fields_definitions();

	// omit any fields which are not permitted for current user.
	foreach ($fields as $field => $def) {
		if (!$def[5]) {
			unset($fields[$field]);
		}
	}
	return $fields;
}

function astcontact_fields_definitions() {
	$fields = array();
	$access = user_access('administer contacts') || user_access('manage contacts') || user_access('use contacts');

	// Default fileds


	$fileds['first_name'] = array(
		'textfield',        	// Field type
		t('First name'),      	// Display name
		true,              	// Required field
		true,               	// Store in separate database field
		array(false, ''),      	// Show in view
		1,                 		// permission
		'',                 	// Default value
		40, 					// Field length
		100,                	// Maximum input length
		t('contact\'s first name'),	// Help text
		NULL);

	$fileds['last_name'] = array(
		'textfield',        	// Field type
		t('Last name'),      	// Display name
		false,              	// Required field
		true,               	// Store in separate database field
		array(false, ''),      	// Show in view
		1,                 		// permission
		'',                 	// Default value
		40, 					// Field length / options
		100,                	// Maximum input length
		t('contact\'s last name'),	// Help text
		NULL);

	$fileds['phone'] = array(
		'textfield',        	// Field type
		t('phone'),      		// Display name
		false,             		// Required field
		true,               	// Store in separate database field
		array(true, ''),       	// Show in view
		1,               	// permission
		'',                 	// Default value
		40, 					// Field length / options
		50,                		// Maximum input length
		t('contact\'s phone number'),	// Help text
		NULL);

	$fileds['mail'] = array(
		'textfield',        	// Field type
		t('E-mail'),      		// Display name
		false,              		// Required field
		true,               	// Store in separate database field
		array(true, 'style="color: red;"'),       	// Show in view
		1,                	// permission
		'',                 	// Default value
		40, 					// Field length / options
		250,                	// Maximum input length
		t('contact\'s e-mail address'),	// Help text
		NULL);

	$fileds['company'] = array(
		'textfield',        	// Field type
		t('Company'),      		// Display name
		false,              		// Required field
		true,               	// Store in separate database field
		array(true, ''),       	// Show in view
		1,                	// permission
		'',                 	// Default value
		40, 					// Field length / options
		250,                	// Maximum input length
		t('contact\'s company name'),	// Help text
		NULL);

	$fileds['country'] = array(
		'select',				// field type
		t('Country'), 			// display name
		false, 					// required
		true, 					// store in separate db column
		array(true, ''),       	// Show in view
		1,				// permission
		'',						// default value
		astcontact_country_list(),	// options
		false,					// multiple
		t('contact\'s country'), 		// Help Text
		NULL);					// extra

	$fileds['city'] = array(
		'textfield',        	// Field type
		t('City'),      		// Display name
		false,              		// Required field
		true,               	// Store in separate database field
		array(true, ''),       	// Show in view
		1,               	// permission
		'',                 	// Default value
		40, 					// Field length / options
		150,                	// Maximum input length
		t('contact\'s city'),	// Help text
		NULL);

	$fileds['address'] = array(
		'textfield',        	// Field type
		t('Address'),      		// Display name
		false,              	// Required field
		true,               	// Store in separate database field
		array(true, ''),       	// Show in view
		1,               	// permission
		'',                 	// Default value
		60, 					// Field length / options
		250,                	// Maximum input length
		t('contact\'s address'),	// Help text
		NULL);

	$fileds['address2'] = array(
		'textfield',        	// Field type
		t('Address2'),      		// Display name
		false,              	// Required field
		true,               	// Store in separate database field
		array(true, ''),       	// Show in view
		1,               	// permission
		'',                 	// Default value
		60, 					// Field length / options
		250,                	// Maximum input length
		t('contact\'s address'),	// Help text
		NULL);

	$fileds['zip'] = array(
		'textfield',        	// Field type
		t('Zip'),      			// Display name
		false,             		// Required field
		true,               	// Store in separate database field
		array(true, ''),       	// Show in view
		1,               	// permission
		'',                 	// Default value
		10, 					// Field length / options
		10,                		// Maximum input length
		t('contact\'s zip code'),	// Help text
		NULL);

	$fileds['fax'] = array(
		'textfield',        	// Field type
		t('fax'),      			// Display name
		false,             		// Required field
		true,               	// Store in separate database field
		array(true, ''),       	// Show in view
		1,               	// permission
		'',                 	// Default value
		40, 					// Field length / options
		50,                		// Maximum input length
		t('contact\'s fax number'),	// Help text
		NULL);

	$fileds['url'] = array(
		'url',        			// Field type
		t('Url'),      			// Display name
		false,             		// Required field
		true,               	// Store in separate database field
		array(true, ''),       	// Show in view
		1,              	// permission
		'',                 	// Default value
		60, 					// Field length / options
		255,                	// Maximum input length
		t('contact\'s url'),	// Help text
		NULL);

	$fileds['job'] = array(
		'textfield',       		// Field type
		t('Job'),      			// Display name
		false,             		// Required field
		true,               	// Store in separate database field
		array(true, ''),       	// Show in view
		1,               	// permission
		'',                 	// Default value
		40, 					// Field length / options
		100,                	// Maximum input length
		t('contact\'s job/occupation'),	// Help text
		NULL);

	$fileds['description'] = array(
		'textarea',       		// Field type
		t('Description'),      	// Display name
		false,             		// Required field
		true,               	// Store in separate database field
		array(true, ''),       	// Show in view
		1,                 	// permission
		'',                 	// Default value
		60, 					// Field length / options
		4,                	// Maximum input length
		t('contact\'s description/services (max 1000 chars)'),	// Help text
		NULL);

	return $fileds;
}


/**
 * Returns a list of countries as an array
 */
function astcontact_country_list() {
	$countries = array();

	$countries['0'] = '[Select]';
	$countries['United Kingdom'] = 'United Kingdom';
	$countries['USA'] = 'USA';
	$countries['Sweden'] = 'Sweden';
	$countries['Norway'] = 'Norway';
	$countries['Denmark'] = 'Denmark';
	$countries['Spain'] = 'Spain';
	$countries['Philippines'] = 'Philippines';
	$countries['Thailand'] = 'Thailand';
	$countries['Canada'] = 'Canada';
	$countries['OTHER'] = 'OTHER';

	return $countries;
}


?>