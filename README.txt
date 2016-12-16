# To precompile assets for production mode run:
RAILS_RELATIVE_URL_ROOT="/blacklight" rake assets:precompile

# To run in production mode in background:
RAILS_RELATIVE_URL_ROOT="/blacklight" rails s -e production -d


# Changelog
12/16/16 - advanced search plugin for Blacklight was monkey-patched to fix a problem caused by the forceful use of 'dismax'; with 'dismax', range queries on `publishDate` of the form [1900 TO 1930] would only return the endpoints, not the actual range.; The file lib/parsing_nesting/tree.rb has been added to remove the forceful use of 'dismax' (see git commit 4b56f6abd2bf36632098a6e2848bc4883511c8cf); Solution was based on: http://stackoverflow.com/questions/18171242/using-the-extended-dismax-query-parser-in-blacklight 
