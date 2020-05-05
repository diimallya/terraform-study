/*

This script creates Access-Groups provided as per input in data directories.

*/
locals {
    json_resourcegroup = jsondecode(file("${path.module}/11-resource-group.json"))
    json_accessgroup = jsondecode(file("${path.module}/21-access-group.json"))
    
    // Access policies for resource groups
    json_ap_rg = jsondecode(file("${path.module}/31-access-policies-rg.json")) 
    json_ap_srvc_in_rg = jsondecode(file("${path.module}/32-access-policies-services-in-rg.json")) //Access policies for services in a resource group
    json_ap_srvc_notin_rg = jsondecode(file("${path.module}/33-access-policies-services-notin-rg.json")) // Access policies for services without a resource group
    json_ap_cluster_instances = jsondecode(file("${path.module}/34-access-policies-cluster-instances.json")) //Access policies for specific cluster instances

    json_users = jsondecode(file("${path.module}/41-users.json"))
}

//create all access groups by taking input from 02-access-group.json
resource "ibm_iam_access_group" "res_accessGroup" {
	  count	    = length(local.json_accessgroup.access-groups)

  	name  		= local.json_accessgroup.access-groups[count.index].access-group-name
  	description = local.json_accessgroup.access-groups[count.index].access-group-desc
}

// create a set with key value pair, with AG name as key and AG's ID as value. This would be required to add AG users and Policies to the corresponding AG using it's name. 
locals {
  all_ag_set = {
    for ag in ibm_iam_access_group.res_accessGroup:
      ag.name => ag.id
  }
}

// create all AG users's memberGroup resource and add it to corresponding AG using its ID from the all_ag_set
resource "ibm_iam_access_group_members" "res_temp1" {
  count = length(local.json_users.users)

  access_group_id = local.all_ag_set[ (local.json_users.users[count.index].access-group-name) ]
  ibm_ids         = local.json_users.users[count.index].user
}


// Import required Resource Group configurations required.
data "ibm_resource_group" "data_rg" {
  count = length(local.json_resourcegroup.resource-groups)

  name = local.json_resourcegroup.resource-groups[count.index].resource-group
} 


// create a set with key value pair, with RG name as key and RG's ID as value. This would be required to add RG users and Policies to the corresponding RG using it's name. 
locals {
  all_rg_set = {
    for rg in data.ibm_resource_group.data_rg:
      rg.name => rg.id
  }
}

// Create all access policies pertaining to resource groups.
resource "ibm_iam_access_group_policy" "res_temp2" {
  count = length(local.json_ap_rg.access-policies)

  access_group_id = local.all_ag_set[ (local.json_ap_rg.access-policies[count.index].access-group-name) ]
  roles           = local.json_ap_rg.access-policies[count.index].access-policy.access
  resources  {
    resource_group_id = local.all_rg_set[ (local.json_ap_rg.access-policies[count.index].access-policy.resource-group-name) ]
    attributes =  local.json_ap_rg.access-policies[count.index].access-policy.attributes
  }
}

// Create all access policies pertaining to services of a region i.e witout resource-group.
resource "ibm_iam_access_group_policy" "res_temp3" {
  count = length(local.json_ap_srvc_notin_rg.access-policies)

  access_group_id = local.all_ag_set[ (local.json_ap_srvc_notin_rg.access-policies[count.index].access-group-name) ]
  roles        = local.json_ap_srvc_notin_rg.access-policies[count.index].access-policy.access
  resources  {
    service   = local.json_ap_srvc_notin_rg.access-policies[count.index].access-policy.service
    region    = local.json_ap_srvc_notin_rg.access-policies[count.index].access-policy.region
  }
}


// Create all access policies pertaining to services of a resource group.
resource "ibm_iam_access_group_policy" "res_temp4" {
  count = length(local.json_ap_srvc_in_rg.access-policies)

  access_group_id = local.all_ag_set[ (local.json_ap_srvc_in_rg.access-policies[count.index].access-group-name) ]
  roles        = local.json_ap_srvc_in_rg.access-policies[count.index].access-policy.access
  resources  {
    service   = local.json_ap_srvc_in_rg.access-policies[count.index].access-policy.service
    resource_group_id = local.all_rg_set[ (local.json_ap_srvc_in_rg.access-policies[count.index].access-policy.resource-group-name) ]
  }
}

// Import required cluster configurations requried defind policies for specific cluster instances
data "ibm_container_cluster" "data_clusters" {
  count = length(local.json_ap_cluster_instances.access-policies)

  cluster_name_id = local.json_ap_cluster_instances.access-policies[count.index].access-policy.cluster-name
  resource_group_id = local.all_rg_set[ (local.json_ap_cluster_instances.access-policies[count.index].access-policy.resource-group-name) ]
}


// create all AG policy resource and add it to corresponding AG using its ID from the all_ag_set
resource "ibm_iam_access_group_policy" "res_temp5" {
  count = length(local.json_ap_cluster_instances.access-policies)

  access_group_id = local.all_ag_set[ (local.json_ap_cluster_instances.access-policies[count.index].access-group-name) ]
  roles        = local.json_ap_cluster_instances.access-policies[count.index].access-policy.access
  resources {
    service           = "containers-kubernetes"
    resource_instance_id = data.ibm_container_cluster.data_clusters[count.index].id
  }
  
}

