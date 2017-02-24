package org.openwis.security.saml;

import java.util.List;

import org.fao.geonet.ApplicationContextHolder;
import org.fao.geonet.domain.User;
import org.fao.geonet.kernel.security.GeonetworkAuthenticationProvider;
import org.fao.geonet.repository.UserRepository;
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
		UserRepository userRepository = ApplicationContextHolder.get().getBean(UserRepository.class);
		
		String email = credential.getNameID().getValue();
		List<User> users = userRepository.findAll();
		for(User u:users){
			for(String emailAddress:u.getEmailAddresses()){
				if(emailAddress.equals(email)){
					User user = (User)authProvider.loadUserByUsername(u.getUsername());
					Authentication authentication = new UsernamePasswordAuthenticationToken(user, user.getPassword(), user.getAuthorities());
					SecurityContextHolder.getContext().setAuthentication(authentication);	
					return user;
				}
			}
		}
		
		return null;		
	}
	
}
