package ojw28.orm.servlet;

import java.io.*;
import java.util.*;
import java.util.logging.FileHandler;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.xml.parsers.*;

/**
 * Servlet implementation class TestServlet
 */
public class OrmServlet extends HttpServlet {

    private static Logger mLogger = Logger.getLogger("ojw28.orm.servlet.OrmServlet");
	private static final long serialVersionUID = 1L;
	
	private ArrayList<ServletRequestHandler> mHandlers = new ArrayList<ServletRequestHandler>();
	
	private MapHandler mMapHandler;
	private ItemDefHandler mComponentLibrary;
	private PlacedItemHandler mItemManager;
	private UserHandler mUserHandler;
	DocumentBuilderFactory mFactory = DocumentBuilderFactory.newInstance();
	
    /**
     * Default constructor. 
     */
	public OrmServlet() {
	}
	
	public void init() throws ServletException
	{
	    try {
	        FileHandler lLogger = new FileHandler("orm.log");
	        Logger.getLogger("ojw28.orm.servlet.OrmServlet").addHandler(lLogger);
	        Logger.getLogger("ojw28.orm.servlet.ItemDefHandler").addHandler(lLogger);
	        Logger.getLogger("ojw28.orm.servlet.MapHandler").addHandler(lLogger);
	        Logger.getLogger("ojw28.orm.servlet.PlacedItemHandler").addHandler(lLogger);
	        Logger.getLogger("ojw28.orm.servlet.DbConnectionPool").addHandler(lLogger);
	    } catch (IOException e) {
	    	System.err.println("Critical Error : Couldn't create log file");
	    	e.printStackTrace();
	    	System.exit(1);
	    }
	    
		try
		{			
			mComponentLibrary = new ItemDefHandler();
			mItemManager = new PlacedItemHandler();
			mMapHandler = new MapHandler();
			mUserHandler = new UserHandler();
			
			mHandlers.add(mItemManager);
			mHandlers.add(mMapHandler);
			mHandlers.add(mComponentLibrary);
			mHandlers.add(mUserHandler);
			
			mLogger.info("Servlet successfully initialised");
		}
		catch(Exception lE)
		{
			mLogger.log(Level.SEVERE, "Exception caught while initiating servlet", lE);
		}
	}
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
	{
		String lRequest = request.getPathInfo();
		if(lRequest != null)
		{
			for(ServletRequestHandler lHandler : mHandlers)
			{
				if(lRequest.startsWith(lHandler.getUrlExt()))
				{
					lHandler.handleRequest(request, response);
					return;
				}
			}
		}
	}  	
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) 
	    throws ServletException, IOException {
		doGet(request,response);
	}   
	
}
