import dns from 'node:dns';
import { Db, MongoClient } from 'mongodb';

let client: MongoClient | null = null;
let dnsConfigured = false;

export class MongoDbService {
  async getDb(): Promise<Db | null> {
    const uri = process.env.MONGODB_URI;
    const dbName = process.env.MONGODB_DB ?? 'communityops';

    if (!uri) {
      return null;
    }

    this.configureDns();

    client ??= new MongoClient(uri);
    await client.connect();
    return client.db(dbName);
  }

  private configureDns(): void {
    if (dnsConfigured) {
      return;
    }

    const servers = (process.env.DNS_SERVERS ?? '1.1.1.1,8.8.8.8')
      .split(',')
      .map((server) => server.trim())
      .filter(Boolean);

    if (servers.length > 0) {
      dns.setServers(servers);
    }

    dns.setDefaultResultOrder('ipv4first');
    dnsConfigured = true;
  }
}
