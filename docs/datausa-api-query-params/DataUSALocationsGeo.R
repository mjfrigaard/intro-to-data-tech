
DataUSALocationsGeo <- tibble::tribble(
      ~`column name`,                                                                                                                          ~description,
              "id",                                                                                                                           "unique ID",
            "name", "if there are no conflicts, will be the same as name_long, otherwise will be suffixed by addition geography (ex. Suffolk County, MA)",
       "name_long",                                                                     "the shortest version of the attribute name (ex. Suffolk County)",
    "display_name",                                                                                         "cleaned names, used for profile page titles",
        "url_name",                                                                                                     "slug name used in URL structure",
        "sumlevel",                                                                                                                  "attribute sumlevel",
      "image_link",                                                                                                      "link to image source on flickr",
    "image_author",                                                                                                            "image credit from flickr",
      "image_meta",                                                                             "any information about the image's content, if available"
    )
