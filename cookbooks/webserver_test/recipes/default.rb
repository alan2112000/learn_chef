# Install the Apache package.
package 'apache2'

# Start and enable the httpd service.
service 'apache2' do
  action [:enable, :start]
end

# Serve a custom home page.
file '/var/www/html/index.html' do
  content '<html>
  <body>
    <h1>hello world</h1>
  </body>
</html>'
end
