package ojw28.orm.utils;


import java.sql.*;
import java.util.*;
import java.util.logging.Logger;

import org.apache.commons.dbcp.*;
import org.apache.commons.pool.*;
import org.apache.commons.pool.impl.*;

/**
 * A pool of connections to the openroommap database. Connections are
 * not in auto-commit mode by default, so it is necessary to peform a
 * commit or rollback before returning the connection to the pool.
 * @author ojw28
 */
public class DbConnectionPool {

    private static Logger mLogger = Logger.getLogger("ojw28.orm.servlet.DbConnectionPool");
	private static DbConnectionPool mSingleton = null;

	private GenericObjectPool mPool;
	private int mAccessCount = 0;
	
	static
	{
		try {
			mSingleton = new DbConnectionPool();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	private DbConnectionPool() throws Exception
	{
		createPool();
	}
	
	public static DbConnectionPool getSingleton()
	{
		return mSingleton;
	}

	public Connection getConnection() throws SQLException
	{
		mAccessCount++;
		if((mAccessCount % 100) == 0)
		{
			mLogger.fine("Active\t"+mPool.getNumActive()+"\tIdle\t"+mPool.getNumIdle());
		}
		return java.sql.DriverManager.getConnection("jdbc:apache:commons:dbcp:openroommap");
	}
		
	private void createPool() throws Exception
	{
		mPool = new GenericObjectPool();

		Properties props = new Properties();
		props.setProperty("user", "orm");
		props.setProperty("password", "openroommap");
		ConnectionFactory cf =
			new DriverConnectionFactory(new org.postgresql.Driver(),
					"jdbc:postgresql://localhost:5432/openroommap",
					props);

		KeyedObjectPoolFactory kopf = new GenericKeyedObjectPoolFactory(null, 10);

		new PoolableConnectionFactory(cf,mPool,kopf,null,false,false);

		for(int i = 0; i < 5; i++) {
			mPool.addObject();
		}

		// PoolingDataSource pds = new PoolingDataSource(gPool);
		PoolingDriver pd = new PoolingDriver();
		pd.registerPool("openroommap", mPool);

		for(int i = 0; i < 5; i++) {
			mPool.addObject();
		}
		
		mLogger.info("Created connection pool");
		mLogger.info("Active\t"+mPool.getNumActive()+"\tIdle\t"+mPool.getNumIdle());
	}
}
