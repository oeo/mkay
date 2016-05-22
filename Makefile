export NODE_ENV = test
export TAKY_DEV = 1

main:
	if [ -a build ] ; \
	then \
			rm -rf build/ ; \
	fi;
	mkdir build
	iced --no-header --output build --compile src

r:
	$(MAKE)
	node build/module.js

