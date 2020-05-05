variable access-groups {
  description = "List of access-groups"
  type        = "list"
  default = [
    {
			"access-group-name": "CLOUDMANAGEMENT-ADMINS",
			"access-group-desc": "System Administrators cloud-management"
		},
		{
			"access-group-name": "APPDEV-USERS",
			"access-group-desc": "Full stack Developers for appdev-cloudnative"
		},
		{
			"access-group-name": "APPDEV-ENVIRONMENT-ADMINS",
			"access-group-desc": "System Administrators for appdev-cloudnative"
		},
		{
			"access-group-name": "APPDEV-ADMINS",
			"access-group-desc": "System Administrators for appdev-cloudnative"
		},
		{
			"access-group-name": "INTEGRATION-ADMINS",
			"access-group-desc": "System Administrators for appdev-cloudnative"
		},
		{
			"access-group-name": "DATA-ADMINS",
			"access-group-desc": "System Administrators for business-data"
		},
		{
			"access-group-name": "BUSINESS-AUTOMATION-ADMINS",
			"access-group-desc": "System Administrators for business-automation"
		}
  ]
}
