library(shiny)
library(miniUI)
library(shinyFiles)

#https://github.com/thomasp85/shinyFiles

fileApp <- function() {

  # Our ui will be a simple gadget page, which
  # simply displays the time in a 'UI' output.
  ui <- miniPage(
    shinyFilesButton('files', label='File select', title='Please select a file', multiple=FALSE)
  )

  server <- function(input, output) {

    shinyFileChoose(input, 'files', root=c(root='.'))

  }

   viewer <- dialogViewer(600,dialogName = 'choosefile')
  runGadget(ui, server, viewer = viewer)

}

#fileApp()

# Now all that's left is sharing this addin -- put this function
# in an R package, provide the registration metadata at
# 'inst/rstudio/addins.dcf', and you're ready to go!
