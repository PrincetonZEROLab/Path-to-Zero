.PHONY: start_nb start_game

start_nb:
	jupyter lab --allow-root --no-browser --port 8888 --NotebookApp.custom_display_url=http://${CODESPACE_NAME}-8888.app.github.dev

start_game:
	julia --project -q -i -e "using Pkg; Pkg.instantiate(); using GenieFramework; Genie.loadapp(); up(); print(\"***\n\nNavigate to the following url to play the game\nhttp://${CODESPACE_NAME}-8000.app.github.dev\n***\n\n\")"