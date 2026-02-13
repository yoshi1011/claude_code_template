# カスタム MCP サーバー

このディレクトリには、カスタムMCPサーバーのソースコードを配置します。
コンテナ内では `/home/claude/mcp-servers` にマウントされます。

## ディレクトリ構造の例

```
mcp-servers/
├── my-node-server/
│   ├── package.json
│   ├── index.js
│   └── ...
└── my-python-server/
    ├── pyproject.toml
    ├── server.py
    └── ...
```

## Node.js MCPサーバーの例

```javascript
// mcp-servers/my-server/index.js
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new McpServer({ name: "my-server", version: "1.0.0" });

// ツールの定義
server.tool("hello", "挨拶を返す", { name: { type: "string" } }, async ({ name }) => ({
  content: [{ type: "text", text: `Hello, ${name}!` }],
}));

const transport = new StdioServerTransport();
await server.connect(transport);
```

対応する `config/.mcp.json` の設定:

```json
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["/home/claude/mcp-servers/my-server/index.js"]
    }
  }
}
```

## Python MCPサーバーの例

```python
# mcp-servers/my-server/server.py
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("my-server")

@mcp.tool()
def hello(name: str) -> str:
    """挨拶を返す"""
    return f"Hello, {name}!"

if __name__ == "__main__":
    mcp.run(transport="stdio")
```

対応する `config/.mcp.json` の設定:

```json
{
  "mcpServers": {
    "my-server": {
      "command": "uv",
      "args": ["run", "--directory", "/home/claude/mcp-servers/my-server", "server.py"]
    }
  }
}
```

## セットアップ手順

1. このディレクトリにサーバーのソースコードを配置
2. `config/.mcp.json` にサーバーの設定を追加
3. `make build` でコンテナを再ビルド（依存パッケージが必要な場合）
4. `make start` で Claude Code を起動し、MCPサーバーが利用可能か確認
