{% if page.comments && theme.gitalk.enable %}
  <link rel="stylesheet" href="/lib/gitalk/gitalk.css">
  <script src="/lib/gitalk/gitalk.min.js"></script>
   <script type="text/javascript">
		var gitalk = new Gitalk({
		  clientID: '{{ theme.gitalk.client_id }}',
		  clientSecret: '{{ theme.gitalk.client_secret }}',
		  repo: '{{ theme.gitalk.repo }}',
		  owner: '{{ theme.gitalk.owner }}',
		  admin: ['{{ theme.gitalk.admin }}'], 
		  id: location.pathname,
		  distractionFreeMode: '{{ theme.gitalk.distraction_free_mode }}'
		})
		gitalk.render('gitalk-container')           
       </script>
{% endif %}