window.onload = function() {
  //<editor-fold desc="Changeable Configuration Block">

  // the following lines will be replaced by docker/configurator, when it runs in a docker-container
  window.ui = SwaggerUIBundle({
    // url: "/cm-api-2024-1.yaml",
    url: "/v1.46.yaml",
    dom_id: '#swagger-ui',
    deepLinking: true,
    docExpansion: 'none',
    displayRequestDuration: true,
    defaultModelRendering: 'example', //["example"*, "model"]
    presets: [
      SwaggerUIBundle.presets.apis,
      SwaggerUIStandalonePreset
    ],
    plugins: [
      SwaggerUIBundle.plugins.DownloadUrl
    ],
    layout: "StandaloneLayout"
  });

  //</editor-fold>
};
