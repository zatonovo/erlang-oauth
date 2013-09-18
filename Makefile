all: clean compile

clean:
	@rm -rf ebin/*.beam *.beam

compile:
	@test -d ebin || mkdir ebin
	@erl -make

test: clean compile
	@escript test.escript
