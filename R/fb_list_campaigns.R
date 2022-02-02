# list campaigns
#

library(httr)

# GET all addrafts
addrafts <- "https://graph.facebook.com/v12.0/act_YOUR_AD_ACCOUNT_ID/addrafts?fields=account_id, api_version, author_id, created_by, id, is_active, name, publish_status{canceled_count,error_count,fragment_statuses,in_progress_count,initial_count,publish_error,success_count,status}, state, time_created, time_updated&access_token=YOUR_FACEBOOK_ACCESS_TOKEN"

accountno <- "YOUR_AD_ACCOUNT_ID"
baseurl <- "https://graph.facebook.com/v12.0/act_YOUR_AD_ACCOUNT_ID/addrafts"
fields <- paste0("fields=account_id, api_version, author_id, created_by, id, is_active,",
                 "name, publish_status{canceled_count,error_count,fragment_statuses,",
                 "in_progress_count,initial_count,publish_error,success_count,status},",
                 "state, time_created, time_updated")
access_token <- "YOUR_FACEBOOK_ACCESS_TOKEN"

addrafts_url <- paste0(baseurl, "?", fields, "&access_token=", access_token)

a <- httr::GET(URLencode(addrafts_url))

after <- httr::content(a)$paging$cursors$after
addrafts_url <- paste0(addrafts_url, "&after=", after)
b <- httr::GET(URLencode(addrafts_url))

content(b)

# parse addrafts url

fields <- "account_id, addraft_fragments.summary(true).limit(0), api_version, author_id, created_by, id, is_active, name, publish_status{canceled_count,error_count,fragment_statuses,in_progress_count,initial_count,publish_error,success_count,status}, state, time_created, time_updated"


# httr::GET(addrafts)
#
#
#
# ############## INDIVIDUAL ADDRAFTS #################
#
# # Example of addraft
# addraft1 <- "https://graph.facebook.com/v12.0/23847273825810138?fields=name,summary,account_id,api_version,async_request_set,created_by,author_id,draft_version,id,is_active,ownership_type,state,publish_status,time_created,time_updated,addraft_fragments.limit(1){account_id,action,active_errors,ad_creation_package_config,ad_draft_id,ad_object,ad_object_type,ad_object_id,ancestor_ad_object_ids,conflicts,draft_version,fragment_type,id,fragment_version,parent_ad_object_id,publish_error,publish_status,source,status,time_created,time_updated,validation_status,values,recommendations.limit(1){aco_toggle_extra_data,ad_object_ids,auction_overlap_extra_data,dead_link_extra_data,ecosystem_bid_reduce_l1_cardinality_extra_data,fbjoiner_key,feedback_extra_data,feedback_score,feedback_type,fragmentation_extra_data,is_seen_by_user,lever_limited_extra_data,recommendation_hash_id,recommendation_hash_string,recommendation_type,uneconomical_ads_throttling_extra_data,worst_performing_ad_object_ids}}&access_token=YOUR_FACEBOOK_ACCESS_TOKEN"
# account_id, addraft_fragments.summary(true).limit(0), api_version, author_id, created_by, id, is_active, name, publish_status{canceled_count,error_count,fragment_statuses,in_progress_count,initial_count,publish_error,success_count,status}, state, time_created, time_updated
# httr::GET(addraft1)



fb_list_campaigns <- function(act_id){

}
