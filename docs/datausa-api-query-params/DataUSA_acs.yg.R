DataUSA_acs.yg <- tibble::tribble(
                      ~column.name,                                                        ~description,
                            "year",                                                "4-digit year value",
                             "geo",                                                       "location ID",
                             "age",                                                        "median Age",
                             "pop",                                                        "population",
                 "non_us_citizens",                 "percentage of population that are Non-US Citizens",
            "mean_commute_minutes",                                      "mean Commute Time in Minutes",
                          "income",                                           "median Household Income",
    "owner_occupied_housing_units",               "percentage of housing units that are Owner occupied",
           "median_property_value",                                             "median property value",
       "median_property_value_moe",                            "median property value, margin of error",
                        "pop_rank",                             "rank of population (for its sumlevel)",
                     "income_rank",                                 "rank of income (for its sumlevel)",
                     "us_citizens",                      "percentage of population that are US citizen",
            "non_eng_speakers_pct", "percentage of population that speak a language other than English"
    )
