//
//  ConnectionManager.swift
//  Emby.ApiClient
//


import Foundation

public class ConnectionManager: ConnectionManagerProtocol {
    let clientCapabilities: ClientCapabilities
    let apiClients = [String: ApiClient]()
    let credentialProvider: CredentialProviderProtocol
    let device: DeviceProtocol
    let serverDiscovery: ServerDiscoveryProtocol
    let connectService: ConnectService

    public init(clientCapabilities: ClientCapabilities,
        credentialProvider: CredentialProviderProtocol,
        device: DeviceProtocol,
        serverDiscovery: ServerDiscoveryProtocol,
        connectService: ConnectService) {
            
        self.clientCapabilities = clientCapabilities
        self.credentialProvider = credentialProvider
        self.device = device
        self.serverDiscovery = serverDiscovery
        self.connectService = connectService
    }

    public func getApiClient(item: IHasServerId) -> ApiClient? {
        return getApiClient(item.serverId)
    }
    
    public func getApiClient(serverId: String) -> ApiClient? {
        return apiClients[serverId]
    }
    
    public func getServerInfo(serverId: String) -> ServerInfo? {
        return credentialProvider
            .getCredentials()
            .servers
            .filter({$0.id == serverId})
            .first
    }
    
    public func connect(onSuccess: (ConnectionResult) -> Void, onError: (ErrorType) -> Void) {
        //TODO    
    }
    
    public func connect(server: ServerInfo, onSuccess: (ConnectionResult) -> Void, onError: (ErrorType) -> Void) {
        //TODO
    }
    
    public func connect(server: ServerInfo, options: ConnectionOptions, onSuccess: (ConnectionResult) -> Void, onError: (ErrorType) -> Void) {
        //TODO
    }
    
    public func connect(address: String, onSuccess: (ConnectionResult) -> Void, onError: (ErrorType) -> Void) {
        //TODO
    }
    
    public func logout(onSuccess: () -> Void, onError: () -> Void) {
        //TODO
    }
    
    public func getAvailableServers(onSuccess: ([ServerInfo]) -> Void, onError: (ErrorType?) -> Void) {
        //TODO
        
        var serverDiscoveryFinished = false
        var connectedServersFinished = false

        var serverDiscoveryFailed = false
        var connectedServersFailed = false
        
        var results = [ServerInfo]()
        
        func appendServerDiscoveryInfo(serverDiscoveryInfo: [ServerDiscoveryInfo]) {
            
            for serverDiscoveryInfoEach in serverDiscoveryInfo {
                
                let serverInfo = ServerInfo()
                
                serverInfo.localAddress = serverDiscoveryInfoEach.address!
                serverInfo.id = serverDiscoveryInfoEach.id!
                serverInfo.name = serverDiscoveryInfoEach.name!
                
                results.append(serverInfo)
            }
        }
        
        func appendConnectUserServer(connectUserServer: [ConnectUserServer]?) {
            
            if let connectUserServer = connectUserServer {
                
                for connectUserServerEach in connectUserServer {
                    
                    let serverInfo = ServerInfo()
                    
                    serverInfo.localAddress = connectUserServerEach.getLocalAddress()
                    
                    if let id = connectUserServerEach.getId() {
                        serverInfo.id = id
                    }
                    
                    if let name = connectUserServerEach.getName() {
                        serverInfo.name = name
                    }
                    
                    if let accessToken = connectUserServerEach.getAccessKey() {
                        serverInfo.accessToken = accessToken
                    }
                    
                    results.append(serverInfo)
                }
            }
        }
        
        serverDiscovery.findServers(1000,
            
            onSuccess: { (serverDiscoveryInfo: [ServerDiscoveryInfo]) -> Void in
            
                print("serverDiscovery.findServers finished with \(serverDiscoveryInfo))")
                
                appendServerDiscoveryInfo(serverDiscoveryInfo)
                
                serverDiscoveryFinished = true
                
                if connectedServersFinished {
                    
                    // cannot return error if we have some results from different scan method so return error only if both methods failed
                    
                    if connectedServersFailed {
                        
                        onError(nil)
                        
                    } else {
                        
                        onSuccess(results)
                    }
                }
            
            }, onError: { (error) -> Void in
                
                print("serverDiscovery.findServers failed with \(error))")
                
                serverDiscoveryFinished = true
                serverDiscoveryFailed = true
                
                if connectedServersFinished {
                    
                    // cannot return error if we have some results from different scan method so return error only if both methods failed
                    
                    if connectedServersFailed {
                        
                        onError(nil)
                        
                    } else {
                    
                        onSuccess(results)
                    }
                }
                
        } )
        
        self.Authenticate( connectService, onSuccess: { (userId, connectAccessToken) -> Void in
            
            let response = EmbyApiClient.Response<ConnectUserServers>()
            
            response.completion = { (result: ConnectUserServers?) -> Void in
                
                print("ConnectService.GetServers finished with \(result?.servers))")
                
                appendConnectUserServer(result?.servers)
                
                connectedServersFinished = true
                
                if serverDiscoveryFinished {
                    
                    onSuccess(results)
                }
                
            }
            
            do {
                
                try self.connectService.GetServers(userId, connectAccessToken: connectAccessToken, final: response)
                
            } catch {
                
                print("Failed to ConnectService.GetServers() \(error)")
                
                // cannot return error if we have some results from different scan method so return error only if both methods failed
                
                connectedServersFinished = true
                connectedServersFailed = true
                
                if serverDiscoveryFailed {
                    
                    onError(error)
                    
                } else {
                    
                    onSuccess(results)
                }
                
            }
            
            }) { () -> Void in
                
                connectedServersFinished = true
                connectedServersFailed = true
                
                print("Failed to ConnectService.Authenticate()")
                
                if serverDiscoveryFinished {
                    
                    // cannot return error if we have some results from different scan method so return error only if both methods failed
                    
                    if serverDiscoveryFailed {
                        
                        onError(nil)
                        
                    } else {
                    
                        onSuccess(results)
                    }
                }
        }
    }
    
    public func loginToConnect(username: String, password: String, onSuccess: () -> Void, onError: () -> Void) {
        //TODO
    }
    
    public func createPin(deviceId: String, onSuccess: (PinCreationResult) -> Void, onError: (ErrorType) -> Void) {
        //TODO
    }
    
    public func getPinStatus(pin: PinCreationResult, onSuccess: (PinStatusResult) -> Void, onError: (ErrorType) -> Void) {
        //TODO
    }
    
    public func exchangePin(pin: PinCreationResult, onSuccess: (PinExchangeResult) -> Void, onError: (ErrorType) -> Void) {
        //TODO
    }
    
    public func getResgistrationInfo(featureName: String, connectedServerId: String, onSuccess: (RegistrationInfo) -> Void, onError: (ErrorType) -> Void) {
        //TODO
    }
//}

    func Authenticate(service: ConnectService,
        onSuccess:(userId: String, connectAccessToken: String) -> Void, onError:() -> Void) {
            
            let response = EmbyApiClient.Response<ConnectAuthenticationResult>()
            
            response.completion = { (result: ConnectAuthenticationResult?) -> Void in
                
                print("Authenticate finished with \(result) \(result?.getAccessToken())")
                
                if let
                    userId = result?.getUser()?.getId(),
                    connectAccessToken = result?.getAccessToken() {
                        
                        onSuccess(userId: userId, connectAccessToken: connectAccessToken)
                        
                } else {
                    
                    onError()
                }
            }
            
            service.Authenticate("vedrano", password: "123456", response: response)
    }




//package mediabrowser.apiinteraction.connectionmanager;
//
//import mediabrowser.apiinteraction.*;
//import mediabrowser.apiinteraction.connect.ConnectService;
//import mediabrowser.apiinteraction.device.IDevice;
//import mediabrowser.apiinteraction.discovery.IServerLocator;
//import mediabrowser.apiinteraction.http.HttpHeaders;
//import mediabrowser.apiinteraction.http.HttpRequest;
//import mediabrowser.apiinteraction.http.IAsyncHttpClient;
//import mediabrowser.apiinteraction.network.INetworkConnection;
//import mediabrowser.model.apiclient.*;
//import mediabrowser.model.connect.*;
//import mediabrowser.model.dto.IHasServerId;
//import mediabrowser.model.dto.UserDto;
//import mediabrowser.model.extensions.StringHelper;
//import mediabrowser.model.logging.ILogger;
//import mediabrowser.model.registration.RegistrationInfo;
//import mediabrowser.model.serialization.IJsonSerializer;
//import mediabrowser.model.session.ClientCapabilities;
//import mediabrowser.model.system.PublicSystemInfo;
//import mediabrowser.model.users.AuthenticationResult;
//
//import java.io.UnsupportedEncodingException;
//import java.security.NoSuchAlgorithmException;
//import java.util.*;
//
//public class ConnectionManager implements IConnectionManager {
//    
//    private ICredentialProvider credentialProvider;
//    private INetworkConnection networkConnection;
//    protected ILogger logger;
//    private IServerLocator serverDiscovery;
//    protected IAsyncHttpClient httpClient;
//    
//    private HashMap<String, ApiClient> apiClients = new HashMap<String, ApiClient>();
//    protected IJsonSerializer jsonSerializer;
//    
//    protected String applicationName;
//    protected String applicationVersion;
//    protected IDevice device;
//    protected ClientCapabilities clientCapabilities;
//    protected ApiEventListener apiEventListener;
//    
//    private ConnectService connectService;
//    private ConnectUser connectUser;
//    
//    public ConnectionManager(ICredentialProvider credentialProvider,
//    INetworkConnection networkConnectivity,
//    IJsonSerializer jsonSerializer,
//    ILogger logger,
//    IServerLocator serverDiscovery,
//    IAsyncHttpClient httpClient,
//    String applicationName,
//    String applicationVersion,
//    IDevice device,
//    ClientCapabilities clientCapabilities,
//    ApiEventListener apiEventListener) {
//        
//        this.credentialProvider = credentialProvider;
//        networkConnection = networkConnectivity;
//        this.logger = logger;
//        this.serverDiscovery = serverDiscovery;
//        this.httpClient = httpClient;
//        this.applicationName = applicationName;
//        this.applicationVersion = applicationVersion;
//        this.device = device;
//        this.clientCapabilities = clientCapabilities;
//        this.apiEventListener = apiEventListener;
//        this.jsonSerializer = jsonSerializer;
//        
//        connectService = new ConnectService(jsonSerializer, logger, httpClient, applicationName, applicationVersion);
//        
//        device.getResumeFromSleepObservable().addObserver(new DeviceResumeFromSleepObservable(this));
//    }
//    
//    public ClientCapabilities getClientCapabilities() {
//        return clientCapabilities;
//    }
//    
//    @Override
//    public ApiClient GetApiClient(IHasServerId item) {
//        
//        return GetApiClient(item.getServerId());
//    }
//    
//    @Override
//    public ApiClient GetApiClient(String serverId) {
//        
//        return apiClients.get(serverId);
//    }
//    
//    @Override
//    public ServerInfo getServerInfo(String serverId) {
//        
//        final ServerCredentials credentials = credentialProvider.GetCredentials();
//        
//        for (ServerInfo server : credentials.getServers()){
//            if (StringHelper.EqualsIgnoreCase(server.getId(), serverId)){
//                return  server;
//            }
//        }
//        return null;
//    }
//    
//    @Override
//    public IDevice getDevice(){
//        return this.device;
//    }
//    
//    void OnConnectUserSignIn(ConnectUser user){
//        
//        connectUser = user;
//        
//        // TODO: Fire event
//    }
//    
//    void OnFailedConnection(Response<ConnectionResult> response){
//        
//        logger.Debug("No server available");
//        
//        ConnectionResult result = new ConnectionResult();
//        result.setState(ConnectionState.Unavailable);
//        result.setConnectUser(connectUser);
//        response.onResponse(result);
//    }
//    
//    void OnFailedConnection(Response<ConnectionResult> response, ArrayList<ServerInfo> servers){
//        
//        logger.Debug("No saved authentication");
//        
//        ConnectionResult result = new ConnectionResult();
//        
//        if (servers.size() == 0 && connectUser == null){
//            result.setState(ConnectionState.ConnectSignIn);
//        }
//        else{
//            result.setState(ConnectionState.ServerSelection);
//        }
//        
//        result.setServers(new ArrayList<ServerInfo>());
//        result.setConnectUser(connectUser);
//        
//        response.onResponse(result);
//    }
//    
//    @Override
//    public void Connect(final Response<ConnectionResult> response) {
//        
//        if (clientCapabilities.getSupportsOfflineAccess())
//        {
//            NetworkStatus networkAccess = networkConnection.getNetworkStatus();
//            if (!networkAccess.getIsNetworkAvailable())
//            {
//                // TODO: for offline access
//                //return await GetOfflineResult().ConfigureAwait(false);
//            }
//        }
//        
//        logger.Debug("Entering initial connection workflow");
//        
//        GetAvailableServers(new GetAvailableServersResponse(logger, this, response));
//    }
//    
//    void Connect(final ArrayList<ServerInfo> servers, final Response<ConnectionResult> response){
//        
//        // Sort by last date accessed, descending
//        Collections.sort(servers, new ServerInfoDateComparator());
//        Collections.reverse(servers);
//        
//        if (servers.size() == 1)
//        {
//            Connect(servers.get(0), new ConnectionOptions(), new ConnectToSingleServerListResponse(response));
//            return;
//        }
//        
//        // Check the first server for a saved access token
//        if (servers.size() == 0 || tangible.DotNetToJavaStringHelper.isNullOrEmpty(servers.get(0).getAccessToken()))
//        {
//            OnFailedConnection(response, servers);
//            return;
//        }
//        
//        ServerInfo firstServer = servers.get(0);
//        Connect(firstServer, new ConnectionOptions(), new FirstServerConnectResponse(this, servers, response));
//    }
//    
//    @Override
//    public void Connect(final ServerInfo server,
//    final Response<ConnectionResult> response) {
//        
//        Connect(server, new ConnectionOptions(), response);
//    }
//    
//    @Override
//    public void Connect(final ServerInfo server,
//    ConnectionOptions options,
//    final Response<ConnectionResult> response) {
//        
//        ArrayList<ConnectionMode> tests = new ArrayList<ConnectionMode>();
//        tests.add(ConnectionMode.Manual);
//        tests.add(ConnectionMode.Local);
//        tests.add(ConnectionMode.Remote);
//        
//        // If we've connected to the server before, try to optimize by starting with the last used connection mode
//        if (server.getLastConnectionMode() != null)
//        {
//            tests.remove(server.getLastConnectionMode());
//            tests.add(0, server.getLastConnectionMode());
//        }
//        
//        boolean isLocalNetworkAvailable = networkConnection.getNetworkStatus().GetIsAnyLocalNetworkAvailable();
//        
//        // Kick off wake on lan on a separate thread (if applicable)
//        boolean sendWakeOnLan = server.getWakeOnLanInfos().size() > 0 && isLocalNetworkAvailable;
//        
//        if (sendWakeOnLan){
//            BeginWakeServer(server);
//        }
//        
//        long wakeOnLanSendTime = System.currentTimeMillis();
//        
//        TestNextConnectionMode(tests, 0, isLocalNetworkAvailable, server, wakeOnLanSendTime, options, response);
//    }
//    
//    void TestNextConnectionMode(final ArrayList<ConnectionMode> tests,
//        final int index,
//        final boolean isLocalNetworkAvailable,
//        final ServerInfo server,
//        final long wakeOnLanSendTime,
//        final ConnectionOptions options,
//        final Response<ConnectionResult> response){
//            
//            if (index >= tests.size()){
//                
//                OnFailedConnection(response);
//                return;
//            }
//            
//            final ConnectionMode mode = tests.get(index);
//            final String address = server.GetAddress(mode);
//            boolean enableRetry = false;
//            boolean skipTest = false;
//            int timeout = 15000;
//            
//            if (mode == ConnectionMode.Local){
//                
//                if (!isLocalNetworkAvailable){
//                    logger.Debug("Skipping local connection test because local network is unavailable");
//                    skipTest = true;
//                }
//                enableRetry = true;
//                timeout = 10000;
//            }
//                
//            else if (mode == ConnectionMode.Manual){
//                
//                if (StringHelper.EqualsIgnoreCase(address, server.getLocalAddress())){
//                    logger.Debug("Skipping manual connection test because the address is the same as the local address");
//                    skipTest = true;
//                }
//                else if (StringHelper.EqualsIgnoreCase(address, server.getRemoteAddress())){
//                    logger.Debug("Skipping manual connection test because the address is the same as the remote address");
//                    skipTest = true;
//                }
//            }
//            
//            if (skipTest || tangible.DotNetToJavaStringHelper.isNullOrEmpty(address))
//            {
//                TestNextConnectionMode(tests, index + 1, isLocalNetworkAvailable, server, wakeOnLanSendTime, options, response);
//                return;
//            }
//            
//            TryConnect(address, timeout, new TestNextConnectionModeTryConnectResponse(this, server, tests, mode, address, timeout, options, index, isLocalNetworkAvailable, wakeOnLanSendTime, enableRetry, logger, response));
//    }
//    
//    void OnSuccessfulConnection(final ServerInfo server,
//        final PublicSystemInfo systemInfo,
//        final ConnectionMode connectionMode,
//        final ConnectionOptions connectionOptions,
//        final Response<ConnectionResult> response) {
//            
//            final ServerCredentials credentials = credentialProvider.GetCredentials();
//            
//            if (!tangible.DotNetToJavaStringHelper.isNullOrEmpty(credentials.getConnectAccessToken()))
//            {
//                EnsureConnectUser(credentials, new EnsureConnectUserResponse(this, server, credentials, systemInfo, connectionMode, connectionOptions, response));
//            } else {
//                
//                AfterConnectValidated(server, credentials, systemInfo, connectionMode, true, connectionOptions, response);
//            }
//    }
//    
//    void AddAuthenticationInfoFromConnect(final ServerInfo server,
//        ConnectionMode connectionMode,
//        ServerCredentials credentials,
//        final EmptyResponse response){
//            
//            if (tangible.DotNetToJavaStringHelper.isNullOrEmpty(server.getExchangeToken())) {
//                throw new IllegalArgumentException("server");
//            }
//            
//            logger.Debug("Adding authentication info from Connect");
//            
//            String url = server.GetAddress(connectionMode);
//            
//            url += "/emby/Connect/Exchange?format=json&ConnectUserId=" + credentials.getConnectUserId();
//            
//            HttpRequest request = new HttpRequest();
//            request.setUrl(url);
//            request.setMethod("GET");
//            
//            request.getRequestHeaders().put("X-MediaBrowser-Token", server.getExchangeToken());
//            
//            httpClient.Send(request, new ExchangeTokenResponse(jsonSerializer, server, response));
//    }
//    
//    void AfterConnectValidated(final ServerInfo server,
//        final ServerCredentials credentials,
//        final PublicSystemInfo systemInfo,
//        final ConnectionMode connectionMode,
//        boolean verifyLocalAuthentication,
//        final ConnectionOptions options,
//        final Response<ConnectionResult> response){
//            
//            if (verifyLocalAuthentication && !tangible.DotNetToJavaStringHelper.isNullOrEmpty(server.getAccessToken()))
//            {
//                ValidateAuthentication(server, connectionMode, new AfterConnectValidatedResponse(this, server, credentials, systemInfo, connectionMode, options, response));
//                
//                return;
//            }
//            
//            server.ImportInfo(systemInfo);
//            
//            if (options.getUpdateDateLastAccessed()){
//                server.setDateLastAccessed(new Date());
//            }
//            
//            server.setLastConnectionMode(connectionMode);
//            credentials.AddOrUpdateServer(server);
//            credentialProvider.SaveCredentials(credentials);
//            
//            ConnectionResult result = new ConnectionResult();
//            
//            result.setApiClient(GetOrAddApiClient(server, connectionMode));
//            result.setState(tangible.DotNetToJavaStringHelper.isNullOrEmpty(server.getAccessToken()) ?
//                ConnectionState.ServerSignIn :
//                ConnectionState.SignedIn);
//            
//            result.getServers().add(server);
//            result.getApiClient().EnableAutomaticNetworking(server, connectionMode, networkConnection);
//            
//            if (result.getState() == ConnectionState.SignedIn)
//            {
//                AfterConnected(result.getApiClient(), options);
//            }
//            
//            response.onResponse(result);
//    }
//    
//    @Override
//    public void Connect(final String address, final Response<ConnectionResult> response) {
//        
//        final String normalizedAddress = NormalizeAddress(address);
//        
//        logger.Debug("Attempting to connect to server at %s", address);
//        
//        TryConnect(normalizedAddress, 15000, new ConnectToAddressResponse(this, normalizedAddress, response));
//    }
//    
//    @Override
//    public void Logout(final EmptyResponse response) {
//        
//        logger.Debug("Logging out of all servers");
//        
//        LogoutAll(new LogoutAllResponse(credentialProvider, logger, response, this));
//    }
//    
//    void clearConnectUserAfterLogout() {
//        
//        if (connectUser != null){
//            connectUser = null;
//        }
//    }
//    
//    private void ValidateAuthentication(final ServerInfo server, ConnectionMode connectionMode, final EmptyResponse response)
//    {
//        final String url = server.GetAddress(connectionMode);
//        
//        HttpHeaders headers = new HttpHeaders();
//        headers.SetAccessToken(server.getAccessToken());
//        
//        final HttpRequest request = new HttpRequest();
//        request.setUrl(url + "/emby/system/info?format=json");
//        request.setMethod("GET");
//        request.setRequestHeaders(headers);
//        
//        Response<String> stringResponse = new ValidateAuthenticationResponse(this, jsonSerializer, server, response, request, httpClient, url);
//        
//        httpClient.Send(request, stringResponse);
//    }
//    
//    void TryConnect(String url, int timeout, final Response<PublicSystemInfo> response)
//    {
//        url += "/emby/system/info/public?format=json";
//        
//        HttpRequest request = new HttpRequest();
//        request.setUrl(url);
//        request.setMethod("GET");
//        request.setTimeout(timeout);
//        
//        httpClient.Send(request, new SerializedResponse<PublicSystemInfo>(response, jsonSerializer, PublicSystemInfo.class));
//    }
//    
//    protected ApiClient InstantiateApiClient(String serverAddress) {
//        
//        return new ApiClient(httpClient,
//            jsonSerializer,
//            logger,
//            serverAddress,
//            applicationName,
//            applicationVersion,
//            device,
//            apiEventListener);
//    }
//    
//    private ApiClient GetOrAddApiClient(ServerInfo server, ConnectionMode connectionMode)
//    {
//        ApiClient apiClient = apiClients.get(server.getId());
//        
//        if (apiClient == null){
//            
//            String address = server.GetAddress(connectionMode);
//            
//            apiClient = InstantiateApiClient(address);
//            
//            apiClients.put(server.getId(), apiClient);
//            
//            apiClient.getAuthenticatedObservable().addObserver(new AuthenticatedObserver(this, apiClient));
//        }
//        
//        if (tangible.DotNetToJavaStringHelper.isNullOrEmpty(server.getAccessToken()))
//        {
//            apiClient.ClearAuthenticationInfo();
//        }
//        else
//        {
//            apiClient.SetAuthenticationInfo(server.getAccessToken(), server.getUserId());
//        }
//        
//        return apiClient;
//    }
//    
//    void AfterConnected(ApiClient apiClient, ConnectionOptions options)
//    {
//        if (options.getReportCapabilities()){
//            apiClient.ReportCapabilities(clientCapabilities, new EmptyResponse());
//        }
//        
//        if (options.getEnableWebSocket()){
//            apiClient.OpenWebSocket();
//        }
//    }
//    
//    void OnAuthenticated(final ApiClient apiClient,
//        final AuthenticationResult result,
//        ConnectionOptions options,
//        final boolean saveCredentials)
//    {
//        logger.Debug("Updating credentials after local authentication");
//        
//        ServerInfo server = apiClient.getServerInfo();
//        
//        ServerCredentials credentials = credentialProvider.GetCredentials();
//        
//        if (options.getUpdateDateLastAccessed()){
//            server.setDateLastAccessed(new Date());
//        }
//        
//        if (saveCredentials)
//        {
//            server.setUserId(result.getUser().getId());
//            server.setAccessToken(result.getAccessToken());
//        }
//        else
//        {
//            server.setUserId(null);
//            server.setAccessToken(null);
//        }
//        
//        credentials.AddOrUpdateServer(server);
//        SaveUserInfoIntoCredentials(server, result.getUser());
//        credentialProvider.SaveCredentials(credentials);
//        
//        AfterConnected(apiClient, options);
//        
//        OnLocalUserSignIn(result.getUser());
//    }
//    
//    private void SaveUserInfoIntoCredentials(ServerInfo server, UserDto user)
//    {
//        ServerUserInfo info = new ServerUserInfo();
//        info.setIsSignedInOffline(true);
//        info.setId(user.getId());
//        
//        // Record user info here
//        server.AddOrUpdate(info);
//    }
//    
//    void OnLocalUserSignIn(UserDto user)
//    {
//        // TODO: Fire event
//    }
//    
//    void OnLocalUserSignout(ApiClient apiClient)
//    {
//        // TODO: Fire event
//    }
//    
//    public void GetAvailableServers(final Response<ArrayList<ServerInfo>> response)
//    {
//        logger.Debug("Getting saved servers via credential provider");
//        final ServerCredentials credentials = credentialProvider.GetCredentials();
//        
//        final int numTasks = 2;
//        final int[] numTasksCompleted = {0};
//        final ArrayList<ServerInfo> foundServers = new ArrayList<ServerInfo>();
//        final ArrayList<ServerInfo> connectServers = new ArrayList<ServerInfo>();
//        
//        Response<ArrayList<ServerInfo>> findServersResponse = new FindServersResponse(this, credentials, foundServers, connectServers, numTasksCompleted, numTasks, response);
//        
//        logger.Debug("Scanning network for local servers");
//        
//        FindServers(findServersResponse);
//        
//        EmptyResponse connectServersResponse = new GetConnectServersResponse(logger, connectService, credentials, foundServers, connectServers, numTasks, numTasksCompleted, response, this);
//        
//        if (!tangible.DotNetToJavaStringHelper.isNullOrEmpty(credentials.getConnectAccessToken()))
//        {
//            logger.Debug("Getting server list from Connect");
//            
//            EnsureConnectUser(credentials, connectServersResponse);
//        }
//        else{
//            connectServersResponse.onError(null);
//        }
//    }
//    
//    void EnsureConnectUser(ServerCredentials credentials, final EmptyResponse response){
//        
//        if (connectUser != null && StringHelper.EqualsIgnoreCase(connectUser.getId(), credentials.getConnectUserId()))
//        {
//            response.onResponse();
//            return;
//        }
//        
//        if (!tangible.DotNetToJavaStringHelper.isNullOrEmpty(credentials.getConnectUserId()) && !tangible.DotNetToJavaStringHelper.isNullOrEmpty(credentials.getConnectAccessToken()))
//        {
//            this.connectUser = null;
//            
//            ConnectUserQuery query = new ConnectUserQuery();
//            
//            query.setId(credentials.getConnectUserId());
//            
//            connectService.GetConnectUser(query, credentials.getConnectAccessToken(), new GetConnectUserResponse(this, response));
//        }
//    }
//    
//    void OnGetServerResponse(ServerCredentials credentials,
//        ArrayList<ServerInfo> foundServers,
//        ArrayList<ServerInfo> connectServers,
//        Response<ArrayList<ServerInfo>> response){
//            
//            for(ServerInfo newServer : foundServers){
//                
//                if (tangible.DotNetToJavaStringHelper.isNullOrEmpty(newServer.getManualAddress())) {
//                    newServer.setLastConnectionMode(ConnectionMode.Local);
//                }
//                else {
//                    newServer.setLastConnectionMode(ConnectionMode.Manual);
//                }
//                
//                credentials.AddOrUpdateServer(newServer);
//            }
//            
//            for(ServerInfo newServer : connectServers){
//                
//                credentials.AddOrUpdateServer(newServer);
//            }
//            
//            ArrayList<ServerInfo> cleanList = new ArrayList<ServerInfo>();
//            ArrayList<ServerInfo> existing = credentials.getServers();
//            
//            for(ServerInfo server : existing){
//                
//                // It's not a connect server, so assume it's still valid
//                if (tangible.DotNetToJavaStringHelper.isNullOrEmpty(server.getExchangeToken()))
//                {
//                    cleanList.add(server);
//                    continue;
//                }
//                
//                boolean found = false;
//                
//                for(ServerInfo connectServer : connectServers){
//                    
//                    if (StringHelper.EqualsIgnoreCase(server.getId(), connectServer.getId())){
//                        found = true;
//                        break;
//                    }
//                }
//                
//                if (found)
//                {
//                    cleanList.add(server);
//                }
//                else{
//                    logger.Debug("Dropping server "+server.getName()+" - "+server.getId()+" because it's no longer in the user's Connect profile.");
//                }
//            }
//            
//            // Sort by last date accessed, descending
//            Collections.sort(cleanList, new ServerInfoDateComparator());
//            Collections.reverse(cleanList);
//            
//            credentials.setServers(cleanList);
//            
//            credentialProvider.SaveCredentials(credentials);
//            
//            ArrayList<ServerInfo> clone = new ArrayList<ServerInfo>();
//            clone.addAll(credentials.getServers());
//            
//            response.onResponse(clone);
//    }
//    
//    protected void FindServers(final Response<ArrayList<ServerInfo>> response)
//    {
//        FindServersInternal(response);
//    }
//    
//    protected void FindServersInternal(final Response<ArrayList<ServerInfo>> response)
//    {
//        serverDiscovery.serverDiscoveryInfo.size()(1000, new FindServersInnerResponse(this, response));
//    }
//    
//    void WakeAllServers()
//        {
//            logger.Debug("Waking all servers");
//            
//            for(ServerInfo server : credentialProvider.GetCredentials().getServers()){
//                
//                WakeServer(server, new EmptyResponse());
//            }
//    }
//    
//    private void BeginWakeServer(final ServerInfo info)
//    {
//        Thread thread = new Thread(new BeginWakeServerRunnable(this, info));
//        
//        thread.start();
//    }
//    
//    void WakeServer(ServerInfo info, final EmptyResponse response)
//    {
//        logger.Debug("Waking server: %s, Id: %s", info.getName(), info.getId());
//        
//        ArrayList<WakeOnLanInfo> wakeList = info.getWakeOnLanInfos();
//        
//        final int count = wakeList.size();
//        
//        if (count == 0){
//            logger.Debug("Server %s has no saved wake on lan profiles", info.getName());
//            response.onResponse();
//            return;
//        }
//        
//        final ArrayList<EmptyResponse> doneList = new ArrayList<EmptyResponse>();
//        
//        for(WakeOnLanInfo wakeOnLanInfo : wakeList){
//            
//            WakeServer(wakeOnLanInfo, new WakeServerResponse(doneList, response));
//        }
//    }
//    
//    private void WakeServer(WakeOnLanInfo info, EmptyResponse response) {
//        
//        networkConnection.SendWakeOnLan(info.getMacAddress(), info.getPort(), response);
//    }
//    
//    String NormalizeAddress(String address) throws IllegalArgumentException {
//        
//        if (tangible.DotNetToJavaStringHelper.isNullOrEmpty(address))
//        {
//            throw new IllegalArgumentException("address");
//        }
//        
//        if (StringHelper.IndexOfIgnoreCase(address, "http") == -1)
//        {
//            address = "http://" + address;
//        }
//        
//        return address;
//    }
//    
//    private void LogoutAll(final EmptyResponse response){
//        
//        Object[] clientList = apiClients.values().toArray();
//        
//        final int count = clientList.length;
//        
//        if (count == 0){
//            response.onResponse();
//            return;
//        }
//        
//        final ArrayList<Integer> doneList = new ArrayList<Integer>();
//        
//        for(Object clientObj : clientList){
//            
//            ApiClient client = (ApiClient)clientObj;
//            
//            ApiClientLogoutResponse logoutResponse = new ApiClientLogoutResponse(doneList, count, response, this, client);
//            
//            if (!tangible.DotNetToJavaStringHelper.isNullOrEmpty(client.getAccessToken()))
//            {
//                client.Logout(logoutResponse);
//            }
//            else {
//                logoutResponse.onResponse(false);
//            }
//        }
//        
//        connectUser = null;
//    }
//    
//    public void LoginToConnect(String username, String password, final EmptyResponse response) throws UnsupportedEncodingException, NoSuchAlgorithmException {
//        
//        connectService.Authenticate(username, password, new LoginToConnectResponse(this, credentialProvider, response));
//    }
//    
//    public void CreatePin(String deviceId, Response<PinCreationResult> response)
//    {
//        connectService.CreatePin(deviceId, response);
//    }
//    
//    public void GetPinStatus(PinCreationResult pin, Response<PinStatusResult> response)
//    {
//        connectService.GetPinStatus(pin, response);
//    }
//    
//    public void ExchangePin(PinCreationResult pin, final Response<PinExchangeResult> response)
//    {
//        connectService.ExchangePin(pin, new ExchangePinResponse(credentialProvider, response));
//    }
//    
//    public void GetRegistrationInfo(String featureName, String connectedServerId, Response<RegistrationInfo> response) {
//        
//        FindServers(new GetRegistrationInfoFindServersResponse(this, featureName, connectedServerId, logger, response, credentialProvider, connectService));
//    }
}