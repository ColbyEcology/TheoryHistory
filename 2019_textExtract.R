# 0. Set directories
	wd <- "/Users/cmmoore/ColbyDrive/Projects/HistTheory/get_pdf_data"
	pdf_wd <- paste0(wd, "/pdf")
	text_wd <- paste0(wd, "/text2019")
	if (any(list.files(wd) == text_wd) == F) {
		dir.create(text_wd)	
	}

# 1. Load libraries
	library(package = "pdftools")

# 2. Cleaning functions
	# 2.0. column clean up (from https://stackoverflow.com/questions/42541849/extract-text-from-two-column-pdf-with-r)
	src <- ""
	trim <- function (x) gsub("^\\s+|\\s+$", "", x)
	
	QTD_COLUMNS <- 2
	read_text <- function(text) {
	  result <- ''
	  #Get all index of " " from page.
	  lstops <- gregexpr(pattern =" ", text)
	  #Puts the index of the most frequents ' ' in a vector.
	  stops <- as.integer(names(sort(table(unlist(lstops)),decreasing=TRUE)[1:2]))
	  #Slice based in the specified number of colums (this can be improved)
	  for(i in seq(1, QTD_COLUMNS, by=1))
	  {
	    temp_result <- sapply(text, function(x){
	      start <- 1
	      stop <-stops[i] 
	      if(i > 1)            
	        start <- stops[i-1] + 1
	      if(i == QTD_COLUMNS) #last column, read until end.
	        stop <- nchar(x)+1
	      substr(x, start=start, stop=stop)
	    }, USE.NAMES = FALSE)
	    temp_result <- trim(temp_result)
	    result <- append(result, temp_result)
	  }
	  result
	}

	# 2.1 misc
	pdf_clean <- function(pdf_text_file) {
		a <- paste0(pdf_text_file, collapse = " ") # collapse to 1 string
		b <- read_text(text = a)
		c <- gsub(pattern = "Literature Cited.*", replacement = "" , x = b)
		return(c)
	}

# 3. Import Am. Nat. DOIs for 2019
	ANcsv <- read.csv(file = "https://raw.githubusercontent.com/flodebarre/2020_AmNatHistory/master/data/mergedAmNat_abs.csv", stringsAsFactor = F)
	year <- ANcsv$PublicationYear
	year2019 <- which(year == 2019)
	doi <- ANcsv$DOI[year2019]
	rm(ANcsv); gc()

# 4. Index papers
	file_doi <- paste0(gsub(pattern = "\\.|/", replacement = "_", x = doi), ".pdf")
	pdf_files <- list.files(pdf_wd)
	loc2019 <- which(pdf_files %in% file_doi)

# 5. Read in pdf, convert to text, and save
	n_pdfs <- length(loc2019)
	for (i in 1: n_pdfs) {
		pdf_index_i <- paste0(pdf_wd, "/", pdf_files[i])
		txt_index_i <- paste0(text_wd, "/", sub(pattern = ".pdf", replacement = ".txt", x = pdf_files[i]))

		text_i <- pdf_text(pdf = pdf_index_i); rm(pdf_index_i); gc()
		text_i_clean <- pdf_clean(text_i)
		write(x = text_i_clean, file = txt_index_i)
	}
	