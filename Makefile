NAME = jump
DESCRIPTION = "Jump helps you navigate faster by learning your habits."
HOMEPAGE = https://github.com/gsamokovarov/jump
AUTHOR = "Genadi Samokovarov"
LICENSE = MIT

VERSION = 0.22.0

.PHONY: build
build:
	@go build -o jump

.PHONY: build.linux
build.linux:
	@env GOOS=linux go build -o jump

.PHONY: build.linux.arm
build.linux.arm:
	@env GOOS=linux GOARCH=arm go build -o jump

.PHONY: test
test:
	@go test ./... -cover

.PHONY: lint
lint:
	@go vet ./... && golint ./...

.PHONY: clean
clean:
	@rm -f jump*

.PHONY: pkg
pkg: clean pkg.deb pkg.rpm pkg.linux

.PHONY: pkg.deb
pkg.deb: man build.linux
	@fpm -s dir -t deb -n $(NAME) -v $(VERSION) -a amd64 \
		--deb-compression bzip2 \
		--url $(HOMEPAGE) \
		--description $(DESCRIPTION) \
		--vendor $(AUTHOR) \
		--license $(LICENSE) \
		-m "Genadi Samokovarov <gsamokovarov@gmail.com>" \
		./jump=/usr/bin/jump \
		./man/jump.1=/usr/share/man/man1/jump.1 \
		./man/j.1=/usr/share/man/man1/j.1

.PHONY: pkg.rpm
pkg.rpm: man build.linux
	@fpm -s dir -t rpm -n $(NAME) -v $(VERSION) -a amd64 \
		--rpm-compression bzip2 \
		--url $(HOMEPAGE) \
		--description $(DESCRIPTION) \
		--vendor $(AUTHOR) \
		--license $(LICENSE) \
		-m "Genadi Samokovarov <gsamokovarov@gmail.com>" \
		./jump=/usr/bin/jump \
		./man/jump.1=/usr/share/man/man1/jump.1 \
		./man/j.1=/usr/share/man/man1/j.1

.PHONY: pkg.rpm
pkg.linux: man build.linux
	@mv jump jump_linux_amd64_binary

.PHONY: pkg.rpm
pkg.linux.arm: man build.linux.arm
	@mv jump jump_linux_arm_binary

.PHONY: man
man: ronn
	@ronn ./man/jump.1.ronn --style=dark
	@cp ./man/jump.1 ./man/j.1

.PHONY: ronn
ronn:
	@which -s ronn > /dev/null || gem install ronn
