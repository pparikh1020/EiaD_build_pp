library(reutils)
#Grabbing sample attributes
attribute_finder <- function(xml_list_obj){
  out <- list()
  for (i in 1:length(xml_list_obj)){
    out[[i]] <- xml_list_obj[[i]]$.attrs['attribute_name']
  }
  return(out)
}

value_grabber <- function(attribute, xml_list_obj){
  for (i in 1:length(xml_list_obj)){
    if (attribute %in% (xml_list_obj[[i]]$.attrs)){
      out <- xml_list_obj[[i]]$text
      return(out)
    }
  }
}

# takes SRR run accession as input
# and returns SAMN biosample ID
samn_getter <- function(srr){
  (efetch(c(srr), db = 'sra', retmode = 'xml'))$content %>% str_extract(., 'SAMN\\d+')
}

# uses NCBI sample attribute
# example: SAMN05784633
attribute_df_maker <- function(id){
  # fetch xml object from NCBI
  eutil_grab <- efetch(uid = id, db = 'biosample', retmode = 'xml')
  # extract attributes, convert to list
  xml_list_obj <- eutil_grab[["//Attributes"]] %>% XML::xmlToList()
  biosample_title <-  (eutil_grab[["//Description"]]%>% XML::xmlToList())$Title
  # scan through list obj and find all attributes
  attribute_df <-  attribute_finder(xml_list_obj) %>% as.character() %>% data.frame()
  colnames(attribute_df)[1] <- 'attribute'
  # grab the attributes and stick into DF
  attribute_df <- attribute_df %>% rowwise() %>% mutate(value = value_grabber(attribute, xml_list_obj))
  attribute_df$id = id
  attribute_df <- bind_rows(attribute_df, c(attribute = 'biosample_title', value = biosample_title, 'id' = id))
  return(attribute_df)
}



