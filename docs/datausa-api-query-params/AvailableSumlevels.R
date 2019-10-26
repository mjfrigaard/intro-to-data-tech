
AvailableSumlevels <- tibble::tribble(
    ~sumlevel, ~prefix,                                                           ~description,
     "nation",   "010",                                                    "Aggregate US data",
      "state",   "040",                            "US States (includin D.C. and Puerto Rico)",
     "county",   "050",                                                          "US Counties",
      "place",   "160",                                             "Census Designated Places",
        "msa",   "310",                                        "Metropolitan Statistical Area",
       "puma",   "795", "Public Use Micro Data Sample Area, a census subdivision of US states"
    )
