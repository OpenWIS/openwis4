package org.openwis.security.saml;

import org.fao.geonet.ApplicationContextHolder;
import org.fao.geonet.domain.User;
import org.fao.geonet.kernel.security.GeonetworkAuthenticationProvider;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.saml.SAMLCredential;
import org.springframework.security.saml.userdetails.SAMLUserDetailsService;

public class OpenWISSamlUserDetailsService implements SAMLUserDetailsService{
		
	@Override
	public Object loadUserBySAML(SAMLCredential credential) throws UsernameNotFoundException {
				
		GeonetworkAuthenticationProvider authProvider = ApplicationContextHolder.get()
				.getBean(GeonetworkAuthenticationProvider.class);
		
		
		User user = (User)authProvider.loadUserByUsername("admin");
		Authentication authentication = new UsernamePasswordAuthenticationToken(user, user.getPassword(), user.getAuthorities());
		SecurityContextHolder.getContext().setAuthentication(authentication);		
		
		
		return user;		
	}
	
}
