JSON (JavaScript Object Notation) wrangling (intro + case study)
================

Load the packages

``` r
library(RJSONIO)
library(rjson)
library(jsonlite)
```

# Motivation

This file imports and cleans various JSON data files from the DataUSA
API.

## Why use JSON?

JSON is an object notation language (hence JavaScript Object Notation).
The advantage of using an object representation of data (in contrast to
a relational table-based model) is that the set of attributes for each
object is encapsulated within the object, which results in a flexible
representation.

For example, it may be that one of the objects in the database, compared
to other objects, has only a subset of attributes.

By contrast, in the standard tabular data structure used by a relational
database, all the data points should have the same set of attributes
(i.e., columns and rows).

This flexibility in object representation is important in contexts where
the data cannot (due to variety or type) naturally be decomposed into a
set of structured attributes.

For example, it can be difficult to define the set of attributes that
should be used to represent free text (such as tweets) or images.
However, although this representational flexibility allows us to capture
and store data in a variety of formats, these data still have to be
extracted into a structured format before any analysis can be performed
on them.

There are four JSON data types:

`null`

`true`

`false`

`number`

`string`

Data containers are either 1) square brackets `[ ]` or 2) curly brackets
`{ }`

## Named vs. Unnamed Arrays

**Ordered unnamed arrays** are indicated with the square brackets `[ ]`

  - `[ 1, 2, 3, ... ]`

  - `[ true, true, false, ... ]`

**Named arrays** are built using the curly brackets `{ }`

  - `{ "dollars" : 5, "euros" : 20, ... }`

  - `{ "city" : "Berkeley", "state" : "CA", ... }`

### Nesting JSON data

This is a nested named array.

``` json
{
  "name": ["X", "Y", "Z"],
  "grams": [300, 200, 500],
  "qty": [4, 5, null],
  "new": [true, false, true],
}
```

This is a nested unnamed ordered array

``` json
[
    { "name": "X",
      "grams": 300,
      "qty": 4,
      "new": true },
    { "name": "Y",
      "grams": 200,
      "qty": 5,
      "new": false },
    { "name": "Z",
      "grams": 500,
      "qty": null,
      "new": true}
]
```

## Viewing JSON data in R

We can import the `mario-wide.json` file below using
`readr::read_file()`. To view this object, use the `cat` function. The
square brackets show this is an

``` r
# fs::dir_ls("data/json")
mario_wide <- readr::read_file(file = "data/json/mario-wide.json")
cat(mario_wide)
```

    #>  [
    #>    {"Name" : "Mario", "Age" : 32, "Occupation" : "Plumber"}, 
    #>    {"Name" : "Peach", "Age" : 21, "Occupation" : "Princess"},
    #>    {},
    #>    {"Name" : "Bowser", "Occupation" : "Koopa"}
    #>  ]

Here we see the third item is left blank, and the `Age` for `Bowser` is
left blank.

``` r
MarioWideData <- jsonlite::fromJSON(mario_wide)
MarioWideData
```

    #>      Name Age Occupation
    #>  1  Mario  32    Plumber
    #>  2  Peach  21   Princess
    #>  3   <NA>  NA       <NA>
    #>  4 Bowser  NA      Koopa

``` r
mario_long <- readr::read_file(file = "data/json/mario-long.json")
cat(mario_long)
```

    #>  [
    #>    {
    #>      "Name": "Mario",
    #>      "Age": 32,
    #>      "Occupation": "Plumber",
    #>      "Ranking": 3
    #>    },
    #>    {
    #>      "Name": "Peach",
    #>      "Age": 21,
    #>      "Occupation": "Princess",
    #>      "Ranking": 1
    #>    },
    #>    {
    #>      "Ranking": 2
    #>    },
    #>    {
    #>      "Name": "Bowser",
    #>      "Occupation": "Koopa",
    #>      "Ranking": 4
    #>    }
    #>  ]

``` r
MarioLongData <- jsonlite::fromJSON(mario_long)
MarioLongData
```

    #>      Name Age Occupation Ranking
    #>  1  Mario  32    Plumber       3
    #>  2  Peach  21   Princess       1
    #>  3   <NA>  NA       <NA>       2
    #>  4 Bowser  NA      Koopa       4

## Data USA (datausa.io housing data)

  - Source: [Dallas Texas
    Housing](https://datausa.io/profile/geo/dallas-tx/#housing)

  - Data USA API documentation: [Data USA API
    Documentation](https://github.com/DataUSA/datausa-api/wiki/Data-API#ipeds)

### Components of API requests

The various components of the API request (text string dropped in the
url to download JSON data).

`https://api.datausa.io/api/` = root url

`?show=geo&` = beginning of API request, the `?show=geo` is indicating
the [location
id](https://github.com/DataUSA/datausa-api/wiki/Attribute-API#geo),
which is the following table of information

``` r
source("docs/datausa-api-query-params/DataUSALocationsGeo.R")
knitr::kable(DataUSALocationsGeo)
```

| column name   | description                                                                                                                          |
| :------------ | :----------------------------------------------------------------------------------------------------------------------------------- |
| id            | unique ID                                                                                                                            |
| name          | if there are no conflicts, will be the same as name\_long, otherwise will be suffixed by addition geography (ex. Suffolk County, MA) |
| name\_long    | the shortest version of the attribute name (ex. Suffolk County)                                                                      |
| display\_name | cleaned names, used for profile page titles                                                                                          |
| url\_name     | slug name used in URL structure                                                                                                      |
| sumlevel      | attribute sumlevel                                                                                                                   |
| image\_link   | link to image source on flickr                                                                                                       |
| image\_author | image credit from flickr                                                                                                             |
| image\_meta   | any information about the image’s content, if available                                                                              |

`sumlevel=state&` = below are the possible options for `sumlevel`. We’re
obviously collecting data on the `state`.

``` r
source("docs/datausa-api-query-params/AvailableSumlevels.R")
knitr::kable(AvailableSumlevels)
```

| sumlevel | prefix | description                                                          |
| :------- | :----- | :------------------------------------------------------------------- |
| nation   | 010    | Aggregate US data                                                    |
| state    | 040    | US States (includin D.C. and Puerto Rico)                            |
| county   | 050    | US Counties                                                          |
| place    | 160    | Census Designated Places                                             |
| msa      | 310    | Metropolitan Statistical Area                                        |
| puma     | 795    | Public Use Micro Data Sample Area, a census subdivision of US states |

`force=pums_1yr.ygo&` = The `force` parameter requires the following two
components, `schema_name.table_name`. This, “*Forces the use of a
particular data table.*” Read more about this in the [query
parameters](https://github.com/DataUSA/datausa-api/wiki/Data-API#query-parameters).
I’ve also copied the table below.

``` r
source("docs/datausa-api-query-params/DataUSAQueryParams.R")
knitr::kable(
DataUSAQueryParams)
```

| parameter           | accepted values                                | description                                                                                                                                                                                         |
| :------------------ | :--------------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| force               | schema\_name.table\_name (Example)             | Forces the use of a particular data table.                                                                                                                                                          |
| limit               | integer                                        | Limits the number of rows returned by the query.                                                                                                                                                    |
| order               | any available column name                      | Column name to use for ordering the resulting data array.                                                                                                                                           |
| show (required)     | any available attribute                        | A comma-separated list of attributes to show in the query.                                                                                                                                          |
| sort                | desc or asc                                    | Changes the sort order of the returned data array.                                                                                                                                                  |
| sumlevel (required) | any available sumlevel for the given attribute | This restricts the data fetched to only display the specified sumlevel(s). If more than one “show” attribute is specified, sumlevel must be a comma-separated list with a value for each attribute. |
| required            | any available column name                      | A comma-separated list of column names to be returned in the query.                                                                                                                                 |
| where               | see documentation                              | Advanced filtering of columns, similar to the WHERE clause on SQL.                                                                                                                                  |
| year                | latest, oldest, all, 4-digit year              | Filters the returned data to the given year.                                                                                                                                                        |

So we know this will becoming from the `pums_1yr` schema (`ACS
PUMS 1-year Estimate`)

``` python
class BasePums(db.Model, BaseModel):
    __abstract__ = True
    __table_args__ = {"schema": "pums_1yr"}
    source_title = 'ACS PUMS 1-year Estimate'
```

but we don’t know what the `ygo` is coming from. We can assume it is a
table in the `pums_1yr` shema based on the documentation and [this
script
file](https://github.com/DataUSA/datausa-api/blob/ab50ea1a0301188532419a4529c32ec9101649a0/scripts/gen_indicies.py),

``` python
'''
Script used to add indexes for PUMS tables
'''
import itertools

lookup = {
    "a": "age",
    "b": "birthplace",
    "c": "cip",
    "d": "degree",
    "s": "sector",
    "g": "geo",
    "i": "naics",
    "o": "soc",
    "r": "race",
    "s": "sex",
    "w": "wage_bin",
    "y": "year",
}

tables = [ # these are the tables...
    'ya',
    'yc',
    'yca',
    'ycb',
    'ycd',
    'ycs',
    'yg',
    'ygb',
    'ygc',
    'ygd',
    'ygi',
    'ygio',
    'ygo', # here is the table 
    'ygor',
    'ygos',
    'ygr',
    'ygs',
    'ygw',
    'yi',
    'yic',
    'yid',
    'yio',
    'yior',
    'yios',
    'yir',
    'yis',
    'yiw',
    'yo',
    'yoas',
    'yoc',
    'yocd',
    'yod',
    'yor',
    'yos',
    'yow',
]
schema = 'pums_1yr' # and this is the schema

# <---> The rest of this file is omitted <--->
```

`limit=5`

## Download all location attributes

This API request will get all the location attributes.

``` r
utils::download.file(url = "http://api.datausa.io/attrs/geo/", 
              destfile = "data/json/geo_attrs.json")
```

### Import the JSON data

Now we can import these data using `readr::read_file()`

``` r
geo_attrs_json <- readr::read_file("data/json/geo_attrs.json")
```

``` bash
# cd data/json
# ls
# head geo_attrs.json
```

This file is in the original format (JSON), but it’s not the way we want
it imported. We can use the `jsonlite::fromJSON()` function.

### Convert JSON to list

We can change the imported file (JSON data) to a `list` using
`jsonlite::fromJSON()`.

``` r
datausa_locations <- jsonlite::fromJSON(geo_attrs_json)
utils::str(datausa_locations)
```

    #>  List of 2
    #>   $ data   : chr [1:36288, 1:10] "pray-mt" "hartsville-trousdale-county-tn" "park-city-mt" "hinsdale-mt" ...
    #>   $ headers: chr [1:10] "url_name" "display_name" "name" "image_link" ...

There are two items in this list (`data` and `header`), so we’ll extract
the `$data` portion using `base::as.data.frame()`.

### Convert list to data.frame

This will take the `data` element with two dimensions (`1:36288` and
`1:10` ) and create a `data.frame` with `36,288` observations and `10`
variables.

``` r
DataUsaLocData <- base::as.data.frame(datausa_locations$data)
# assign the names to the data frame
colnames(DataUsaLocData) <- datausa_locations$headers
DataUsaLocData %>% dplyr::glimpse(78)
```

    #>  Observations: 36,288
    #>  Variables: 10
    #>  $ url_name     <fct> pray-mt, hartsville-trousdale-county-tn, park-city-mt,…
    #>  $ display_name <fct> "Pray, MT", "Hartsville/Trousdale County, TN", "Park C…
    #>  $ name         <fct> "Pray", "Hartsville/Trousdale County, TN", "Park City"…
    #>  $ image_link   <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    #>  $ sumlevel     <fct> 160, 160, 160, 160, 160, 160, 160, 160, 160, 160, 160,…
    #>  $ image_meta   <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    #>  $ image_author <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    #>  $ keywords     <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    #>  $ id           <fct> 16000US3059725, 16000US4732742, 16000US3056575, 16000U…
    #>  $ name_long    <fct> Pray, Hartsville/Trousdale County, Park City, Hinsdale…

We assign the column names using the `headers` object.

## Download the ACS (Metropolitan Statistical Area)

The `sort=desc` is pretty self explanatory (sort the data descending),
but the `force` parameter needs a bit more explanation. We know from
this table that it is the ACS survey and it will contain these columns
and headers.

``` r
# fs::dir_tree("docs/datausa-api-query-params")
source("docs/datausa-api-query-params/DataUSA_acs.yg.R")
knitr::kable(
DataUSA_acs.yg)
```

| column.name                     | description                                                       |
| :------------------------------ | :---------------------------------------------------------------- |
| year                            | 4-digit year value                                                |
| geo                             | location ID                                                       |
| age                             | median Age                                                        |
| pop                             | population                                                        |
| non\_us\_citizens               | percentage of population that are Non-US Citizens                 |
| mean\_commute\_minutes          | mean Commute Time in Minutes                                      |
| income                          | median Household Income                                           |
| owner\_occupied\_housing\_units | percentage of housing units that are Owner occupied               |
| median\_property\_value         | median property value                                             |
| median\_property\_value\_moe    | median property value, margin of error                            |
| pop\_rank                       | rank of population (for its sumlevel)                             |
| income\_rank                    | rank of income (for its sumlevel)                                 |
| us\_citizens                    | percentage of population that are US citizen                      |
| non\_eng\_speakers\_pct         | percentage of population that speak a language other than English |

So now that I have an idea what these data will have, I can run the code
below to download the ACS `latest` data.

``` r
utils::download.file(url = "https://api.datausa.io/api/?sort=desc&force=acs.yg&show=geo&sumlevel=msa&year=latest", 
              destfile = "data/json/datausa-acs-yg.json")
```

I can import these into the `asc_yg` list

``` r
asc_yg <- jsonlite::fromJSON("data/json/datausa-acs-yg.json")
str(asc_yg)
```

    #>  List of 5
    #>   $ data   : chr [1:945, 1:19] "2016" "2016" "2016" "2016" ...
    #>   $ headers: chr [1:19] "year" "geo" "age" "age_moe" ...
    #>   $ source :List of 5
    #>    ..$ link            : chr "http://www.census.gov/programs-surveys/acs/"
    #>    ..$ org             : chr "Census Bureau"
    #>    ..$ table           : chr "acs_5yr.yg"
    #>    ..$ supported_levels:List of 1
    #>    .. ..$ geo: chr [1:8] "nation" "state" "county" "msa" ...
    #>    ..$ dataset         : chr "2016 ACS 5-year Estimate"
    #>   $ subs   :List of 1
    #>    ..$ force: chr "acs_5yr"
    #>   $ logic  :'data.frame':    1 obs. of  5 variables:
    #>    ..$ link            : chr "http://www.census.gov/programs-surveys/acs/"
    #>    ..$ org             : chr "Census Bureau"
    #>    ..$ table           : chr "acs_5yr.yg"
    #>    ..$ supported_levels:'data.frame':    1 obs. of  1 variable:
    #>    .. ..$ geo:List of 1
    #>    .. .. ..$ : chr [1:8] "nation" "state" "county" "msa" ...
    #>    ..$ dataset         : chr "2016 ACS 5-year Estimate"

We can see this is a list of `5` elements. I will convert this to a
data.frame and assing the column names like I did above.

``` r
AcsYgData <- base::as.data.frame(asc_yg$data)
colnames(AcsYgData) <- asc_yg$headers
AcsYgData %>% dplyr::glimpse(78)
```

    #>  Observations: 945
    #>  Variables: 19
    #>  $ year                         <fct> 2016, 2016, 2016, 2016, 2016, 2016, 20…
    #>  $ geo                          <fct> 31000US10100, 31000US10140, 31000US101…
    #>  $ age                          <fct> 38.2, 43, 33.9, 35.3, 38.9, 41.2, 40.3…
    #>  $ age_moe                      <fct> 0.6, 0.3, 0.2, 0.2, 0.6, 0.4, 0.2, 0.1…
    #>  $ pop                          <fct> 42430, 71233, 168774, 38213, 18760, 98…
    #>  $ pop_moe                      <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    #>  $ non_us_citizens              <fct> 0.0255008, 0.0322323, 0.0289559, 0.014…
    #>  $ mean_commute_minutes         <fct> 12.6572, 23.5186, 16.7492, 16.8806, 28…
    #>  $ income                       <fct> 53682, 44521, 46473, 44041, 11296, 493…
    #>  $ income_moe                   <fct> 2316, 1713, 1571, 2036, 1218, 1450, 45…
    #>  $ owner_occupied_housing_units <fct> 0.686812, 0.670865, 0.616734, 0.641983…
    #>  $ median_property_value        <fct> 147300, 159400, 98200, 113100, 90900, …
    #>  $ median_property_value_moe    <fct> 5571, 4296, 1916, 4453, 6343, 2741, 18…
    #>  $ estimate                     <fct> 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,…
    #>  $ age_rank                     <fct> 533, 140, 800, 749, 473, 254, 333, 347…
    #>  $ pop_rank                     <fct> 676, 481, 251, 729, 923, 389, 156, 79,…
    #>  $ income_rank                  <fct> 215, 577, 501, 599, 945, 386, 941, 279…
    #>  $ us_citizens                  <fct> 0.974499, 0.967768, 0.971044, 0.985005…
    #>  $ non_eng_speakers_pct         <fct> 0.062796, 0.0901031, 0.157721, 0.04873…

Now, I only wanted a few columns from the data set, so I can change the
name of `geo` to `id`, and convert the `pop` and `pop_rank` to integers.

``` r
AcsYgData <- AcsYgData %>%
  dplyr::mutate(
    id = geo, 
    pop = as.integer(pop),
    pop_rank = as.integer(pop_rank))
AcsYgData %>% dplyr::glimpse(78)
```

    #>  Observations: 945
    #>  Variables: 20
    #>  $ year                         <fct> 2016, 2016, 2016, 2016, 2016, 2016, 20…
    #>  $ geo                          <fct> 31000US10100, 31000US10140, 31000US101…
    #>  $ age                          <fct> 38.2, 43, 33.9, 35.3, 38.9, 41.2, 40.3…
    #>  $ age_moe                      <fct> 0.6, 0.3, 0.2, 0.2, 0.6, 0.4, 0.2, 0.1…
    #>  $ pop                          <int> 571, 824, 163, 505, 196, 940, 405, 818…
    #>  $ pop_moe                      <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    #>  $ non_us_citizens              <fct> 0.0255008, 0.0322323, 0.0289559, 0.014…
    #>  $ mean_commute_minutes         <fct> 12.6572, 23.5186, 16.7492, 16.8806, 28…
    #>  $ income                       <fct> 53682, 44521, 46473, 44041, 11296, 493…
    #>  $ income_moe                   <fct> 2316, 1713, 1571, 2036, 1218, 1450, 45…
    #>  $ owner_occupied_housing_units <fct> 0.686812, 0.670865, 0.616734, 0.641983…
    #>  $ median_property_value        <fct> 147300, 159400, 98200, 113100, 90900, …
    #>  $ median_property_value_moe    <fct> 5571, 4296, 1916, 4453, 6343, 2741, 18…
    #>  $ estimate                     <fct> 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,…
    #>  $ age_rank                     <fct> 533, 140, 800, 749, 473, 254, 333, 347…
    #>  $ pop_rank                     <int> 641, 425, 170, 700, 915, 322, 64, 767,…
    #>  $ income_rank                  <fct> 215, 577, 501, 599, 945, 386, 941, 279…
    #>  $ us_citizens                  <fct> 0.974499, 0.967768, 0.971044, 0.985005…
    #>  $ non_eng_speakers_pct         <fct> 0.062796, 0.0901031, 0.157721, 0.04873…
    #>  $ id                           <fct> 31000US10100, 31000US10140, 31000US101…

``` r
AcsLocationData <- AcsYgData %>%
  # arrange this by the population rank
  dplyr::arrange(pop_rank) %>%
  # join to the location data
  dplyr::left_join(x = .,
                   y = DataUsaLocData, 
                   by = "id") %>% 
    # convert this to character
    dplyr::mutate(
        image_link = as.character(image_link)
    )
AcsLocationData %>% dplyr::glimpse(78)
```

    #>  Observations: 945
    #>  Variables: 29
    #>  $ year                         <fct> 2016, 2016, 2016, 2016, 2016, 2016, 20…
    #>  $ geo                          <fct> 31000US35620, 31000US14460, 31000US168…
    #>  $ age                          <fct> 38, 38.7, 39.8, 38.3, 36.4, 38.5, 33.8…
    #>  $ age_moe                      <fct> 0.1, 0.1, 0.2, 0.2, 0.2, 0.2, 0.1, 0.1…
    #>  $ pop                          <int> 216, 644, 714, 711, 710, 702, 697, 690…
    #>  $ pop_moe                      <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    #>  $ non_us_citizens              <fct> 0.13067, 0.0864998, 0.0218063, 0.02547…
    #>  $ mean_commute_minutes         <fct> 34.408, 29.1462, 22.3091, 20.7984, 22.…
    #>  $ income                       <fct> 69211, 77809, 47751, 49929, 54842, 592…
    #>  $ income_moe                   <fct> 323, 497, 872, 742, 953, 893, 797, 801…
    #>  $ owner_occupied_housing_units <fct> 0.515285, 0.613438, 0.675045, 0.638782…
    #>  $ median_property_value        <fct> 403300, 379200, 149700, 185400, 203400…
    #>  $ median_property_value_moe    <fct> 877, 996, 1533, 2231, 3412, 1554, 2921…
    #>  $ estimate                     <fct> 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,…
    #>  $ age_rank                     <fct> 565, 494, 392, 524, 672, 507, 804, 129…
    #>  $ pop_rank                     <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,…
    #>  $ income_rank                  <fct> 35, 14, 444, 362, 185, 110, 284, 91, 3…
    #>  $ us_citizens                  <fct> 0.86933, 0.9135, 0.978194, 0.974523, 0…
    #>  $ non_eng_speakers_pct         <fct> 0.387082, 0.237711, 0.050364, 0.070609…
    #>  $ id                           <chr> "31000US35620", "31000US14460", "31000…
    #>  $ url_name                     <fct> new-york-northern-new-jersey-long-isla…
    #>  $ display_name                 <fct> "New York-Newark-Jersey City, NY-NJ-PA…
    #>  $ name                         <fct> "New York-Newark-Jersey City, NY-NJ-PA…
    #>  $ image_link                   <chr> "https://flic.kr/p/sMUuZw", "https://f…
    #>  $ sumlevel                     <fct> 310, 310, 310, 310, 310, 310, 310, 310…
    #>  $ image_meta                   <fct> NA, NA, NA, NA, NA, NA, NA, "Old Orcha…
    #>  $ image_author                 <fct> rowens27, Emmanuel Huybrechts, Brent M…
    #>  $ keywords                     <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    #>  $ name_long                    <fct> "New York-Newark-Jersey City, NY-NJ-PA…
