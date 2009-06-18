package ojw28.orm.servlet;

import javax.servlet.http.*;
import javax.xml.parsers.*;
import javax.xml.transform.*;
import javax.xml.transform.dom.*;
import javax.xml.transform.stream.*;
import org.w3c.dom.*;
import java.io.*;

public abstract class ServletRequestHandler {
		
	private DOMImplementation mBuilderImpl;
	private TransformerFactory mTransformerFactory;
	private String mUrlExt;
	
	public ServletRequestHandler(String iUrlExt) throws ParserConfigurationException, TransformerConfigurationException
	{	
		mUrlExt = iUrlExt;
		
		DocumentBuilderFactory lFactory = DocumentBuilderFactory.newInstance();
		DocumentBuilder lBuilder = lFactory.newDocumentBuilder();
		mBuilderImpl = lBuilder.getDOMImplementation();

		mTransformerFactory = TransformerFactory.newInstance();
	}

	protected void writeXmlResponse(Document iDocument, HttpServletResponse response) throws IOException, TransformerException
	{
		DOMSource domSource = new DOMSource(iDocument);
		StreamResult streamResult = new StreamResult(response.getWriter());
		Transformer lTransformer = mTransformerFactory.newTransformer();
		lTransformer.transform(domSource, streamResult); 
	}  	
	
	protected Document createDocument(String iName)
	{
		return mBuilderImpl.createDocument(null, iName, null);
	}

	protected String getCrsid(HttpServletRequest request)
	{
		HttpSession lSession = request.getSession();
		Object lUser = lSession.getAttribute("RavenRemoteUser");
		if(lUser == null)
		{
			return "no_auth";
		}
		else
		{
			return (String) lUser;
		}
	}
	
	public String getUrlExt()
	{
		return mUrlExt;
	}
	
	public abstract void handleRequest(HttpServletRequest request, HttpServletResponse response);
	

}