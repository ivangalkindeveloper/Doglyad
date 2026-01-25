public protocol DHttpError: Error {}

public class DHttpApiError: DHttpError {}

public class DHttpConnectionError: DHttpError {}
