UNAME_S := $(shell uname -s)
NGX_MODULES = --with-compat  --with-threads --with-http_addition_module \
     --with-http_auth_request_module   --with-http_gunzip_module --with-http_gzip_static_module  \
     --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module \
     --with-http_slice_module  --with-http_stub_status_module --with-http_sub_module \
     --with-stream --with-stream_realip_module --with-stream_ssl_preread_module
ifeq ($(UNAME_S),Linux)
    NGX_OPT = $(NGX_MODULES) \
       --with-file-aio --with-http_ssl_module --with-stream_ssl_module  \
       --with-cc-opt='-g -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' \
       --with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie'
endif
ifeq ($(UNAME_S),Darwin)
    NGX_OPT = $(NGX_MODULES)
endif

prepare-nginx:
	curl -o $(OUT_DIR)/nginx.tar.gz http://nginx.org/download/nginx-$(NGINX_VERSION).tar.gz
	mkdir -p $(OUT_DIR)/nginx
	tar -C $(OUT_DIR)/nginx -xzf $(OUT_DIR)/nginx.tar.gz --strip-components 1
	rm $(OUT_DIR)/nginx.tar.gz
	cd $(OUT_DIR)/nginx && ./configure $(NGX_OPTS)

prepare-nginx-local:
	cd $(NGINX_PATH) && auto/configure $(NGX_OPTS)

doc:
	rm -rf target/doc
	RUSTFLAGS=-Awarnings cargo doc --no-deps --quiet -j`nproc`
	echo "<meta http-equiv=refresh content=0;url=nginx/index.html>" > target/doc/index.html

publish-doc: doc
	ghp-import -n target/doc
	git push -fq https://${GITHUB_TOKEN}@github.com/arvancloud/nginx-rs.git gh-pages
