## Add age uncertainty to fossil tips in a BEAST2 XML file
# xml_file - the input XML file, which should contain the complete BEAST2 setup except the age uncertainty
# age_table - a table containing three columns: taxa for the taxon name, min_age and max_age respectively for the lower and upper age bounds
# save_file - path to save the new XML file, if NULL will overwrite xml_file
add_age_uncertainty_BEAST2 = function(xml_file, age_table, save_file) {
  package_list = c("ape", "xml2", "magrittr")
  for(pck in package_list) {
    if(!require(pck, character.only = T)) {
      install.packages(pck)
      library(pck, character.only = T)
    }
  }
  
  col.names = c("taxa", "min_age", "max_age")
  if(any(!col.names %in% colnames(age_table))) stop("age_table needs to have columns taxa, min_age and max_age")
  
  if(is.null(save_file)) save_file = xml_file
  
  # loading stuff
  template = read_xml(xml_file)
  nfossils = length(age_table$taxa)
  treeid = xml_attr(xml_find_first(template,"run/state/tree"), "id")
  
  # setting up operator for fossil tips
  operator = as_xml_document(list(operator = structure(list(), spec="sa.evolution.operators.SampledNodeDateRandomWalker", 
                                                       windowSize="1.", tree=paste0("@", treeid), weight="5.0")))
  taxset = as_xml_document(list(taxonset = structure(list(), id = "fossilTaxa", spec="TaxonSet")))
  
  # handling tip dates uncertainty for fossils
  for(ii in 1:nfossils) {
    tip_id = paste0(age_table$taxa[ii])
    
    xml_add_child(taxset, as_xml_document(list(taxon = structure(list(), id = tip_id, spec="Taxon"))))
    xml_add_child(operator, as_xml_document(list(samplingDates = structure(list(),
                                                                           id = paste0("samplingDate.", tip_id), spec="sa.evolution.tree.SamplingDate", taxon = paste0("@", tip_id),
                                                                           lower = as.character(age_table$min_age[ii]), upper = as.character(age_table$max_age[ii])))))
  }
  
  # putting operator in xml
  xml_add_child(operator, taxset)
  xml_find_first(template,"run") %>% xml_add_child(operator)
  
  # writing final file
  write_xml(template, save_file)
}