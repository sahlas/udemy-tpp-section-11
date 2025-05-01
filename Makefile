install:
	$(echo VAR=hello)
	echo $VAR

build:
	python -m build --sdist --wheel ./
