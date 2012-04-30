#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <event2/event.h>
#include <event2/buffer.h>
#include <event2/http.h>
#include <event2/http_struct.h>
#include "Pubnub.h"

void context_free(struct request_context *ctx) {

	evhttp_connection_free(ctx->cn);
	event_base_free(ctx->base);

	if (ctx->buffer)
		evbuffer_free(ctx->buffer);

	evhttp_uri_free(ctx->uri);

	free(ctx);
}
struct evbuffer *request_url(
		char *host,
		short port,
		char *url,
		void *callback

) {
	struct request_context *ctx = 0;
	ctx = calloc(1, sizeof(*ctx));
	if (!ctx)
		return 0;

	ctx->uri = evhttp_uri_parse(host);
	if (!ctx->uri)
		return 0;
	printf("\n\n");
	ctx->base = event_base_new();
	if (!ctx->base)
		return 0;

	ctx->buffer = evbuffer_new();

	if (ctx->cn == NULL)
	{
		if (ctx->cn)
			evhttp_connection_free(ctx->cn);
		ctx->cn = evhttp_connection_base_new(ctx->base, NULL,
				evhttp_uri_get_host(ctx->uri),
				evhttp_uri_get_port(ctx->uri) != -1 ? evhttp_uri_get_port(ctx->uri) : 80);

	}
	ctx->req = evhttp_request_new(callback, ctx);

	evhttp_add_header(ctx->req->output_headers, "Host", evhttp_uri_get_host(ctx->uri));
	evhttp_add_header(ctx->req->output_headers,"V", "3.1");
	evhttp_add_header(ctx->req->output_headers,"User-Agent",  "C");
	evhttp_add_header(ctx->req->output_headers,"Accept-Encoding",  "gzip");

	evhttp_connection_set_timeout(ctx->cn,-1);
	evhttp_make_request(ctx->cn, ctx->req, EVHTTP_REQ_GET, url);
	event_base_loop(ctx->base ,EVLOOP_NONBLOCK);
	event_base_dispatch(ctx->base);

	struct evbuffer *retData = 0;
	if (ctx->ok)
	{

		retData = ctx->buffer;
		ctx->buffer = 0;
	}
	context_free(ctx);
	return retData;
}
