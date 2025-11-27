"""Health check endpoint for monitoring"""
import sys
from monitoring import HealthCheck, metrics
from logger import app_logger

def main():
    """Run health check and return status"""
    try:
        health_status = HealthCheck.get_health_status()
        
        if health_status['healthy']:
            print("Status: Healthy")
            print(f"Checks: {len(health_status['checks'])} passed")
            
            # Print metrics summary
            metrics_data = metrics.get_metrics()
            print(f"\nMetrics:")
            print(f"  Uptime: {metrics_data['uptime_seconds']:.0f}s")
            print(f"  CPU: {metrics_data['system'].get('cpu_percent', 0):.1f}%")
            print(f"  Memory: {metrics_data['system'].get('memory_percent', 0):.1f}%")
            
            return 0
        else:
            print("Status: Unhealthy")
            for check_name, check_data in health_status['checks'].items():
                if check_data['status'] != 'ok':
                    print(f"  {check_name}: {check_data['message']}")
            return 1
            
    except Exception as e:
        print(f"Health check failed: {str(e)}")
        app_logger.error(f"Health check error: {str(e)}")
        return 1

if __name__ == '__main__':
    sys.exit(main())
